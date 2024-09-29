package main

import (
	"bytes"
	"context"
	"fmt"
	"net/http"
	"strings"

	"github.com/sourcegraph/conc/iter"
	"github.com/sourcegraph/go-diff/diff"
)

var links = []string{
	"https://github.com/WojciechMatuszewski/programming-notes/commit/faeae7964e4b3903f5bcbd139c2613f134ff8865.diff",
	"https://github.com/WojciechMatuszewski/programming-notes/commit/5c53523cac0003708d96dcafb420ce918d608eb8.diff",
	"https://github.com/WojciechMatuszewski/programming-notes/commit/ce7eb2fc7c0ad25bc0b95213fa32274a533bc053.diff",
}

func main() {
	diffs := iter.Map(links, func(url *string) string {
		return fetchDiff(context.Background(), *url)
	})

	content := strings.TrimSpace(strings.Join(diffs, "\n"))
	fmt.Println(content)
}

func fetchDiff(ctx context.Context, url string) string {
	client := &http.Client{}

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		panic(err)
	}

	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	reader := diff.NewMultiFileDiffReader(resp.Body)
	gitDiff, err := reader.ReadAllFiles()
	if err != nil {
		panic(err)
	}

	var allDiffs []string
	for _, fileDiff := range gitDiff {
		var diffContent bytes.Buffer

		diffContent.WriteString("\n------------\n")
		diffContent.WriteString(strings.ReplaceAll(fileDiff.NewName, "b/", ""))
		diffContent.WriteString("\n------------\n")

		for _, diffChunk := range fileDiff.Hunks {
			diffContent.WriteString(string(diffChunk.Body))
		}

		allDiffs = append(allDiffs, diffContent.String())
	}

	return strings.TrimSpace(strings.Join(allDiffs, "\n----\n"))
}
