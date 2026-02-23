#!/bin/bash

# Script para compilar o wt.sh a partir do main.sh e dos snippets

OUTPUT_FILE="wt.sh"
MAIN_FILE="main.sh"
SNIPPETS_DIR="snippets"

echo "Compilando $OUTPUT_FILE..."

# Inicia o arquivo de saída
cat << 'EOF' > "$OUTPUT_FILE"
#!/bin/bash

# ESTE ARQUIVO É GERADO AUTOMATICAMENTE. NÃO EDITE DIRETAMENTE.
# Edite main.sh ou os arquivos em snippets/ e execute ./compile.sh

EOF

# Lê main.sh linha por linha
IN_LOOP=false
while IFS= read -r line; do
    # Identifica o início do loop que carrega os snippets
    if [[ "$line" =~ "for f in snippets/" ]]; then
        IN_LOOP=true
        echo "# Snippets incluídos" >> "$OUTPUT_FILE"
        
        # Lista os arquivos na ordem que aparecem no main.sh
        # update.sh autocomplete.sh install_completion.sh usage.sh add.sh ls.sh rm.sh
        for f in update.sh autocomplete.sh install_completion.sh usage.sh add.sh ls.sh rm.sh; do
            if [ -f "$SNIPPETS_DIR/$f" ]; then
                echo "Incluindo $f..."
                echo "# --- Início de $f ---" >> "$OUTPUT_FILE"
                # Remove o shebang e comentários iniciais de shellcheck se existirem
                grep -v "^#!" "$SNIPPETS_DIR/$f" | grep -v "^# shellcheck" >> "$OUTPUT_FILE"
                echo "# --- Fim de $f ---" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            fi
        done
        continue
    fi

    # Ignora as linhas dentro do loop de carregamento original
    if [ "$IN_LOOP" = true ]; then
        if [[ "$line" =~ "done" ]]; then
            IN_LOOP=false
            # Também remove o cálculo do SCRIPT_DIR se não for mais necessário, 
            # mas vamos manter a lógica de pular as linhas do loop.
        fi
        continue
    fi

    # Remove a definição de SCRIPT_DIR pois não será necessária no wt.sh compilado
    if [[ "$line" =~ "SCRIPT_DIR=" ]]; then
        continue
    fi

    # Adiciona a linha ao arquivo de saída, exceto se for o shebang original
    if [[ "$line" != "#!/bin/bash" ]]; then
        echo "$line" >> "$OUTPUT_FILE"
    fi

done < "$MAIN_FILE"

chmod +x "$OUTPUT_FILE"
echo "Concluído: $OUTPUT_FILE gerado com sucesso."
