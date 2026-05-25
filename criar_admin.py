from main import app
from dados1 import db1
from model import Funcionarios


def criar_usuario(
    usuario,
    senha,
    nome_completo,
    funcao,
    sexo,
    email=None,
    telefone=None
):

    with app.app_context():

        # Verifica usuário existente
        usuario_existente = Funcionarios.query.filter_by(
            usuario=usuario
        ).first()

        if usuario_existente:
            print(f"⚠️ Usuário '{usuario}' já existe.")
            return

        # Verifica email existente
        if email:

            email_existente = Funcionarios.query.filter_by(
                email=email
            ).first()

            if email_existente:
                print(f"⚠️ Email '{email}' já está em uso.")
                return

        # Criação do funcionário
        funcionario = Funcionarios(
            nome_completo=nome_completo,
            usuario=usuario,
            funcao=funcao.lower(),
            sexo=sexo,
            email=email,
            telefone=telefone
        )

        # Gera hash da senha
        funcionario.set_senha(senha)

        # Salva no banco
        db1.session.add(funcionario)
        db1.session.commit()

        print("===================================")
        print("✅ Usuário criado com sucesso!")
        print(f"ID: {funcionario.id}")
        print(f"Usuário: {funcionario.usuario}")
        print(f"Função: {funcionario.funcao}")
        print("===================================")


def criar_usuarios_padrao():

    usuarios = [

        {
            "usuario": "admin",
            "senha": "admin123",
            "nome_completo": "Administrador do Sistema",
            "funcao": "administrador",
            "sexo": "Masculino",
            "email": "admin@clinica.com"
        },

        {
            "usuario": "recepcao",
            "senha": "recepcao123",
            "nome_completo": "Recepcionista",
            "funcao": "recepcionista",
            "sexo": "Feminino",
            "email": "recepcao@clinica.com"
        },

        {
            "usuario": "medico",
            "senha": "medico123",
            "nome_completo": "Médico Responsável",
            "funcao": "medico",
            "sexo": "Masculino",
            "email": "medico@clinica.com"
        },

        {
            "usuario": "enfermeiro",
            "senha": "enfermeiro123",
            "nome_completo": "Enfermeiro Responsável",
            "funcao": "enfermeiro",
            "sexo": "Feminino",
            "email": "enfermeiro@clinica.com"
        }

    ]

    for usuario in usuarios:
        criar_usuario(**usuario)


if __name__ == "__main__":
    criar_usuarios_padrao()