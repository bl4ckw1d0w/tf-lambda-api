# Nome do projeto
PROJECT_NAME = tf-lambda-api

# Diretório de build
BUILD_DIR = bin
LAMBDA_EXECUTABLE = $(BUILD_DIR)/lambda_function

# Criar o diretório de build, se não existir
.PHONY: all
run: 
	@echo "Compilando o código"
	mkdir -p $(BUILD_DIR)
	go build -o $(LAMBDA_EXECUTABLE) main.go
	@echo "Testando localmente"
	go run main.go

# Limpar os arquivos de build
.PHONY: clean
clean:
	@echo "Limpando os arquivos de build"

	rm -rf $(BUILD_DIR)

# Ajuda
.PHONY: help
help:
	@echo "Comandos disponíveis:"
	@echo "  make build    - Compila o código da função Lambda"
	@echo "  make test     - Executa a função handler localmente"
	@echo "  make clean    - Limpa os arquivos de build"
	@echo "  make help     - Mostra essa mensagem"
