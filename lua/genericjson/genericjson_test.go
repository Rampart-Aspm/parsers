package genericjson_test

import (
	"bytes"
	"context"
	"os"
	"path/filepath"
	"testing"

	"github.com/rampart-aspm/parsers/pkg/domain"
	"github.com/rampart-aspm/parsers/pkg/runtime/lua"
)

func TestGenericjsonLuaParser(t *testing.T) {
	manifestData, err := os.ReadFile("parser.yaml")
	if err != nil {
		t.Fatalf("parser.yaml not found: %v", err)
	}

	p, err := lua.NewLuaParserFromSpec("genericjson", manifestData)
	if err != nil {
		t.Fatalf("failed to create Lua parser: %v", err)
	}

	reportPath := filepath.Join("testdata", "findings.json")
	reportBytes, err := os.ReadFile(reportPath)
	if err != nil {
		t.Fatalf("failed to read test report: %v", err)
	}

	var findings []domain.RawFinding
	for f, err := range p.Parse(context.Background(), bytes.NewReader(reportBytes), domain.ParseContext{}) {
		if err != nil {
			t.Fatalf("lua parse error: %v", err)
		}
		findings = append(findings, f)
	}

	if len(findings) == 0 {
		t.Fatalf("expected at least 1 finding, got 0")
	}
}
