package tests

import (
	"bytes"
	"encoding/json"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/bazelbuild/rules_go/go/runfiles"
	"github.com/latticebuild/graceproc"
)

// Rendering completion requests explicit shutdown; graceproc still requires
// bounded cleanup of every member of the owned process group or Windows job.
type domOutput struct {
	buffer   bytes.Buffer
	signals  chan os.Signal
	once     sync.Once
	complete bool
	valid    bool
}

func (o *domOutput) Write(p []byte) (int, error) {
	n, err := o.buffer.Write(p)
	if bytes.Contains(o.buffer.Bytes(), []byte("</html>")) {
		o.complete = true
		o.valid = bytes.Contains(o.buffer.Bytes(), []byte(`<button aria-label="browser works">ready</button>`)) && bytes.Contains(o.buffer.Bytes(), []byte(`data-native="true"`))
		o.once.Do(func() { o.signals <- os.Interrupt })
	}
	return n, err
}

func TestDeclaredBrowser(t *testing.T) {
	inventory, err := runfiles.Rlocation(os.Getenv("BROWSER_INVENTORY"))
	if err != nil {
		t.Fatal(err)
	}
	contents, err := os.ReadFile(inventory)
	if err != nil {
		t.Fatal(err)
	}
	var files struct {
		Executable string `json:"executable"`
	}
	if err := json.Unmarshal(contents, &files); err != nil {
		t.Fatal(err)
	}
	executable, err := runfiles.Rlocation(files.Executable)
	if err != nil {
		t.Fatal(err)
	}
	executable, err = filepath.EvalSymlinks(executable)
	if err != nil {
		t.Fatal(err)
	}
	fixture, err := runfiles.Rlocation(os.Getenv("BROWSER_PAGE"))
	if err != nil {
		t.Fatal(err)
	}
	fixture, err = filepath.EvalSymlinks(fixture)
	if err != nil {
		t.Fatal(err)
	}
	page := filepath.ToSlash(fixture)
	if !strings.HasPrefix(page, "/") {
		page = "/" + page
	}
	address := (&url.URL{Scheme: "file", Path: page}).String()
	profile := t.TempDir()
	signals := make(chan os.Signal, 2)
	output := domOutput{signals: signals}
	var diagnostics bytes.Buffer
	cmd := exec.Command(executable, "--headless", "--no-sandbox", "--disable-gpu", "--no-first-run", "--no-default-browser-check", "--user-data-dir="+profile, "--dump-dom", address)
	cmd.Stdout, cmd.Stderr = &output, &diagnostics
	cmd.Env = append(os.Environ(), "HOME="+profile, "USERPROFILE="+profile)
	if runtime.GOOS == "linux" {
		// Chromium's Unix socket paths must fit within 108 bytes.
		cmd.Env = append(cmd.Env, "TMPDIR=/tmp")
	}
	var timedOut atomic.Bool
	timer := time.AfterFunc(25*time.Second, func() {
		timedOut.Store(true)
		signals <- os.Interrupt
	})
	defer timer.Stop()
	code, err := graceproc.Run(cmd, signals)
	if timedOut.Load() || err != nil || !output.complete || !output.valid || (code != 0 && code != graceproc.SignalCode(os.Interrupt)) {
		t.Fatalf("browser render/cleanup: timeout=%t code=%d err=%v\n%s\n%s", timedOut.Load(), code, err, output.buffer.String(), diagnostics.String())
	}
	for _, expected := range []string{`<button aria-label="browser works">ready</button>`, `data-native="true"`} {
		if !strings.Contains(output.buffer.String(), expected) {
			t.Fatalf("rendered page is missing %q:\n%s", expected, output.buffer.String())
		}
	}
}
