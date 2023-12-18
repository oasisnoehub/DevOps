# Dockerfile 推荐最佳实践

参考文档：https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

## 使用stage构建镜像
参考文档：https://docs.docker.com/build/building/multi-stage/

查看运行docker容器的大小
```shell
docker ps --size --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Size}}"
```

命名stage：`AS <NAME>`
```Dockerfile
    # syntax=docker/dockerfile:1
    FROM golang:1.21 as build
    WORKDIR /src
    COPY <<EOF /src/main.go
    package main

    import "fmt"

    func main() {
    fmt.Println("hello, world")
    }
    EOF
    RUN go build -o /bin/hello ./main.go

    FROM scratch
    COPY --from=build /bin/hello /bin/hello
    CMD ["/bin/hello"]
```