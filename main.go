package main

import (
    "context"
    "fmt"
    "github.com/aws/aws-lambda-go/lambda"
)

// Request é a estrutura que representa a requisição
type Request struct {
    Name string `json:"name"`
}

// Response é a estrutura que representa a resposta
type Response struct {
    Message string `json:"message"`
}

// Handler é a função que lida com a requisição
func Handler(ctx context.Context, request Request) (Response, error) {
    return Response{
        Message: fmt.Sprintf("Hello, %s!", request.Name),
    }, nil
}

func main() {
    // Configura o handler para o AWS Lambda
    lambda.Start(Handler)
}