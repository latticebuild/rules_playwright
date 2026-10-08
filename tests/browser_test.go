package tests

import (
	"context"
	"encoding/json"
	"github.com/bazelbuild/rules_go/go/runfiles"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"
)

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
		Marker string `json:"marker"`
	}
	if err := json.Unmarshal(contents, &files); err != nil {
		t.Fatal(err)
	}
	marker, err := runfiles.Rlocation(files.Marker)
	if err != nil {
		t.Fatal(err)
	}
	executable, err := runfiles.Rlocation(os.Getenv("BROWSER_PROBE"))
	if err != nil {
		t.Fatal(err)
	}
	scratch := filepath.Join(os.Getenv("TEST_TMPDIR"), "browser-runtime")
	if err := os.MkdirAll(scratch, 0700); err != nil {
		t.Fatal(err)
	}
	ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
	defer cancel()
	cmd := exec.CommandContext(ctx, executable)
	cmd.Env = append(os.Environ(), "BOUND_CACHE=0", "DEBUG=pw:browser", "HOME="+scratch, "USERPROFILE="+scratch, "TMPDIR="+scratch, "TMP="+scratch, "TEMP="+scratch, "PLAYWRIGHT_BROWSERS_PATH="+filepath.Dir(filepath.Dir(marker)))
	output, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("browser probe failed: %v\n%s", err, output)
	}
}
