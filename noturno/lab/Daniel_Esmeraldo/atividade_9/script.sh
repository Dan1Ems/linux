#!/bin/bash

USUARIO=${USER:-$(whoami)}
echo "----------------------GERENCIADOR DE ARQUIVOS----------------------"

adicionar_arquivo() {
	read -p "Informe o nome do arquivo a adicionar: " nome_arquivo

        if [ -f "$nome_arquivo" ]; then
		echo "O arquivo $nome_arquivo já existe no diretório."
        else
                touch "$nome_arquivo"
                echo "Arquivo $nome_arquivo criado com êxito."
                echo "$(date '+%Y-%m-%d %H:%M:%S') - $USUARIO criou arquivo $nome_arquivo" >> log.txt
        fi
}

listar_arquivos() {
	ls -la
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $USUARIO listou os arquivos" >> log.txt
}

buscar_arquivo() {
        read -p "Informe o nome do arquivo a buscar: " nome_arquivo
        resultado=$(find / -type f -name "$nome_arquivo" 2>/dev/null)

        if [ -n "$resultado" ]; then
                echo "$resultado"
	else
		echo "Arquivo não encontrado."
        fi

        echo "$(date '+%Y-%m-%d %H:%M:%S') - $USUARIO procurou por arquivo $nome_arquivo" >> log.txt
}

deletar_arquivo() {
	read -p "Informe o nome do arquivo a deletar: " nome_arquivo
	if [ -f "$nome_arquivo" ]; then
		read -p "Você realmente deseja deletar o arquivo $nome_arquivo? (s/n): " confirm
		if [ "$confirm" == "s" ]; then
			rm "$nome_arquivo"
                        echo "Arquivo $nome_arquivo deletado."
                        echo "$(date '+%Y-%m-%d %H:%M:%S') - $USUARIO removeu o arquivo $nome_arquivo" >> log.txt
		fi
        else
		 echo "Arquivo não encontrado."
	fi
}

gerenciar_permissoes() {
	read -p "Informe o nome do arquivo a gerenciar permissão: " nome_arquivo
        read -p "Informe as permissões que o arquivo terá (Ex: 755): " permissoes
	if [ -f "$nome_arquivo" ]; then
		if [[ "$permissoes" =~ ^[0-7]{3,4}$ ]]; then
			chmod "$permissoes" "$nome_arquivo"
                        echo "Permissão alterada com êxito."
                        echo "$(date '+%Y-%m-%d %H:%M:%S') - $USUARIO alterou a permissão do arquivo $nome_arquivo para $permissoes" >> log.txt
                else
                        echo "Formato inválido. Use 755, 644, etc."
                fi
	else
		echo "Arquivo não encontrado."
        fi
}

gerenciar_proprietarios() {
	read -p "Informe o nome do arquivo/diretório: " nome
	read -p "Informe o novo proprietário (usuário): " dono
	read -p "Informe o novo grupo (opcional, Enter para pular): " grupo

	if ! id "$dono" &>/dev/null; then
		echo "Usuário $dono não existe!"
		return 1
	fi

	if [ -n "$grupo" ] && ! getent group "$grupo" &>/dev/null; then
		echo "Grupo $grupo não existe!"
		return 1
	fi 

	if [ -e "$nome" ]; then
		if [ -n "$grupo" ]; then
			chown "$dono:$grupo" "$nome"
			echo "Proprietário alterado para $dono:$grupo"
			echo "$(date '+%Y-%m-%d %H:%M:%S') - $USUARIO alterou proprietário de $nome para $dono:$grupo" >> log.txt
		else
			chown "$dono" "$nome"
			echo "Proprietário alterado para $dono"
			echo "$(date '+%Y-%m-%d %H:%M:%S') - $USUARIO alterou proprietário de $nome para $dono" >> log.txt
		fi
	else
		echo "Arquivo/diretório não encontrado."
	fi
}

gerar_relatorio() {
	echo "================================RELATÓRIO================================"
	echo "Quantidade de arquivos: $(ls -l | grep "^-" | wc -l)"
	echo "Quantidade de diretórios: $(ls -l | grep "^d" | wc -l)"
	echo "Espaço total usado: $(du -sh . 2>/dev/null | cut -f1)"
	echo ""
	echo "=== PERMISSÕES DOS ARQUIVOS ==="
	ls -la
	echo ""
    	echo "=== LOG DE OPERAÇÕES ==="
    	if [ -f "log.txt" ]; then
        	cat log.txt
    	else
        	echo "Nenhum log encontrado ainda."
    	fi
    	echo ""
        read -p "Pressione ENTER para continuar..."
}

sair() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $USUARIO ---------------Usuário encerrou o programa---------------" >> log.txt
        exit 0
}

while true; do
	PS3="Escolha uma opção: "
	select opcao in "Adicionar arquivo" "Listar arquivos" "Buscar arquivo" "Deletar arquivo" "Gerenciar permissões" "Gerenciar proprietários" "Gerar relatório" "Sair"; do
        	case $opcao in
                	"Adicionar arquivo")
				adicionar_arquivo
                        	;;
                	"Listar arquivos")
				listar_arquivos
                        	;;
                	"Buscar arquivo")
				buscar_arquivo
                        	;;
                	"Deletar arquivo")
				deletar_arquivo
                        	;;
                	"Gerenciar permissões")
				gerenciar_permissoes
                        	;;
			"Gerenciar proprietários")
				gerenciar_proprietarios
				;;
                	"Gerar relatório")
				gerar_relatorio
                        	;;
                	"Sair")
				sair
              	          	;;
        	esac

		break
	done
done
