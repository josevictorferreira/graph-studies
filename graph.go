package main

import (
    "bufio"
    "fmt"
    "log"
    "os"
    "strings"
    "strconv"
    "time"
)

func main () {
  start := time.Now()
  file, err := os.Open("soc-LiveJournal1.txt")
  if err != nil {
    log.Fatal(err);
    return
  }
  defer file.Close()

  scanner := bufio.NewScanner(file)
  graph := make(map[int64][]int64)
  for scanner.Scan() {
    line := scanner.Text()
    if string(line[0]) == "#" {
      continue
    }
    values := strings.Split(line, "\t")
    fromNode, _ := strconv.ParseInt(values[0], 10, 64)
    toNode, _ := strconv.ParseInt(values[1], 10, 64)
    _, valExists := graph[fromNode]
    if valExists {
      graph[fromNode] = append(graph[fromNode], toNode)
    } else {
      graph[fromNode] = []int64{}
    }
  }
  fmt.Println(graph[0])
  elapsed := time.Since(start)
  fmt.Println("Elapsed time: ", elapsed)
}
