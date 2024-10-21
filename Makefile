.PHONY: all build package deploy terraform-init terraform-apply

# Variáveis
BIN_DIR = .bin
LAMBDA_BINARY = $(BIN_DIR)/lambda-binary
LAMBDA_ZIP = $(BIN_DIR)/lambda_compact.zip
GOOS = linux
GOARCH = amd64

# Alvo principal
all: build package terraform-init terraform-apply

# Criar diretório .bin
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Compilar o binário da Lambda
build: $(BIN_DIR)
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(LAMBDA_BINARY) main.go

# Empacotar o binário da Lambda em um arquivo ZIP na raiz
package: build
	cp $(LAMBDA_BINARY) bootstrap         # Copia o binário como 'bootstrap'
	zip -j $(LAMBDA_ZIP) bootstrap        # Usa '-j' para não incluir diretórios no ZIP
	rm bootstrap                          # Remove o arquivo temporário 'bootstrap'
	@echo "Conteúdo do ZIP:"
	@unzip -l $(LAMBDA_ZIP)

# Inicializar o Terraform
terraform-init:
	cd terraform && terraform init

# Aplicar o Terraform
terraform-apply: terraform-init
	cd terraform && terraform apply -auto-approve

# Limpar binários e arquivos ZIP gerados
clean:
	rm -rf $(BIN_DIR)