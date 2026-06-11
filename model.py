import string
import random
from datetime import datetime
from flask import redirect, url_for
from flask_login import UserMixin, current_user
from flask_admin.contrib.sqla import ModelView
from werkzeug.security import generate_password_hash, check_password_hash
from dados1 import db1

# -------------------------
# GERADORES DE ID
# -------------------------

def gerar_id():
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choices(chars, k=5))

def gerar_id_2():
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choices(chars, k=10))

# -------------------------
# FUNCIONÁRIOS
# -------------------------

class Funcionarios(UserMixin, db1.Model):
    __tablename__ = 'funcionarios'

    id = db1.Column(db1.String(10), primary_key=True, default=gerar_id_2)
    nome_completo = db1.Column(db1.String(100), nullable=False)
    usuario = db1.Column(db1.String(70), nullable=False, unique=True)
    funcao = db1.Column(db1.String(30), nullable=False)
    senha = db1.Column(db1.String(200), nullable=False)
    sexo = db1.Column(db1.String(15))
    email = db1.Column(db1.String(100), unique=True)
    telefone = db1.Column(db1.String(20))
    foto = db1.Column(db1.String(200))
    online = db1.Column(db1.Boolean, default=False)
    data_criacao = db1.Column(db1.DateTime, default=datetime.utcnow)
    ultimo_login = db1.Column(db1.DateTime)
    ultimo_logout = db1.Column(db1.DateTime)
    assinatura = db1.Column(db1.Text)

    # SENHA
    def set_senha(self, senha):
        self.senha = generate_password_hash(senha)

    def check_senha(self, senha):
        return check_password_hash(self.senha, senha)

    def get_id(self):
        return str(self.id)


# -------------------------
# PACIENTES
# -------------------------

class Paciente(db1.Model):
    __tablename__ = 'paciente'

    id = db1.Column(db1.String(5), primary_key=True, default=gerar_id)
    nome_completo = db1.Column(db1.String(100), nullable=False)
    data_nascimento = db1.Column(db1.Date)
    sexo = db1.Column(db1.String(15))
    contato = db1.Column(db1.String(100))
    documento = db1.Column(db1.String(30))
    plano = db1.Column(db1.String(50))
    horario_cadastro = db1.Column(db1.DateTime, default=datetime.utcnow)
    observacoes_cadastro = db1.Column(db1.Text)
    responsavel_cadastro = db1.Column(db1.String(100))
    foto = db1.Column(db1.String(100))
    email = db1.Column(db1.String(100), unique=True)
    usuario = db1.Column(db1.String(100), unique=True)
    senha = db1.Column(db1.String(200))
    responsavel = db1.Column(db1.String(100))
    assinatura = db1.Column(db1.Text)
    assinatura_token = db1.Column(db1.String(255))

    # RELACIONAMENTOS
    recepcoes = db1.relationship('Recepcao', backref='paciente', lazy=True)
    planos = db1.relationship('PacientePlano', backref='paciente', lazy=True)

    # SENHA
    def set_senha(self, senha):
        self.senha = generate_password_hash(senha)

    def check_senha(self, senha):
        return check_password_hash(self.senha, senha)


# -------------------------
# RECEPÇÃO
# -------------------------

class Recepcao(db1.Model):
    __tablename__ = 'recepcao'

    id = db1.Column(db1.Integer, primary_key=True)

    paciente_id = db1.Column(db1.String(5),db1.ForeignKey('paciente.id'),nullable=False, unique = True)
    nome_completo = db1.Column(db1.String(200))
    urgencia_recepcao = db1.Column(db1.String(50))
    horario_chegada = db1.Column(db1.DateTime,default=datetime.utcnow)
    chamado = db1.Column(db1.Boolean, default=False)
    destino = db1.Column(db1.String(50))
    observacoes_recepcao = db1.Column(db1.Text)
    responsavel_recepcao = db1.Column(db1.String(100))
    horario_chamada = db1.Column(db1.DateTime)
    fila = db1.Column(db1.String(100))
    status = db1.Column(db1.String(100))
    protocolo = db1.Column(db1.String(100))
    motivo = db1.Column(db1.Text)
    finalizado = db1.Column(db1.Boolean, default=False)
    assinatura1 = db1.Column(db1.Text)
    data_nascimento = db1.Column(db1.Date)
    sexo = db1.Column(db1.String(15))
    Documento = db1.Column(db1.String(30))
    contato = db1.Column(db1.String(100))
    plano = db1.Column(db1.String(50))
    atendimento = db1.Column(db1.String(40))

    # RELACIONAMENTOS
    triagem = db1.relationship('Triagem',backref='recepcao',uselist=False)
    medico = db1.relationship('Medico',back_populates='recepcao',uselist=False)
    vacinacoes = db1.relationship('Vacinacao',backref='recepcao',lazy=True)


# -------------------------
# TRIAGEM
# -------------------------

class Triagem(db1.Model):
    __tablename__ = 'triagem'

    id = db1.Column(db1.Integer, primary_key=True)
    recepcao_id = db1.Column(db1.Integer,db1.ForeignKey('recepcao.id'),nullable=False,unique=True)
    ocupacao = db1.Column(db1.String(100))
    temperatura = db1.Column(db1.String(20))
    freq_cardiaca = db1.Column(db1.Integer)
    freq_respiratoria = db1.Column(db1.Integer)
    peso = db1.Column(db1.String(20))
    altura = db1.Column(db1.String(20))
    queixa_principal = db1.Column(db1.Text)
    doencas_pre_existentes = db1.Column(db1.Text)
    finalizado_triagem = db1.Column(db1.Boolean, default=False)
    responsavel_triagem = db1.Column(db1.String(100))
    observacoes_triagem = db1.Column(db1.Text)
    pressao_arterial = db1.Column(db1.String(20))
    alergia = db1.Column(db1.String(50))
    saturacao = db1.Column(db1.Integer)
    tabagista = db1.Column(db1.Boolean, default=False)
    bebida_alcoolica = db1.Column(db1.Boolean, default=False)
    cirurgia_realizada = db1.Column(db1.Text)
    horario_de_triagem = db1.Column(db1.DateTime,default=datetime.utcnow)
    escala_de_dor = db1.Column(db1.Integer)
    toma_medicacao = db1.Column(db1.Text)
    imc = db1.Column(db1.String(20))
    gestante = db1.Column(db1.Boolean)
    tipo_sanguineo = db1.Column(db1.String(5))
    urgencia_triagem = db1.Column(db1.String(50))

# -------------------------
# MÉDICO
# -------------------------

class Medico(db1.Model):
    __tablename__ = 'medico'

    id = db1.Column(db1.Integer, primary_key=True)
    recepcao_id = db1.Column(db1.Integer,db1.ForeignKey('recepcao.id'),nullable=False,unique=True)
    diagnostico = db1.Column(db1.Text)
    prescricao = db1.Column(db1.Text)
    feedback = db1.Column(db1.Text)
    observacoes_medico = db1.Column(db1.Text)
    cid = db1.Column(db1.String(20))
    finalizado_medico = db1.Column(db1.Boolean,default=False)
    responsavel_medico = db1.Column(db1.String(100))
    horario_de_finalizacao = db1.Column(db1.DateTime,default=datetime.utcnow)

    # RELACIONAMENTOS
    recepcao = db1.relationship('Recepcao',back_populates='medico')

# -------------------------
# PLANOS DOS PACIENTES
# -------------------------

class PacientePlano(db1.Model):
    __tablename__ = 'paciente_planos'

    id = db1.Column(db1.Integer, primary_key=True)
    paciente_id = db1.Column(db1.String(5),db1.ForeignKey('paciente.id'),nullable=False)
    plano_id = db1.Column(
    db1.Integer,db1.ForeignKey('planos.id'),nullable=False)
    data_inicio = db1.Column(db1.Date, nullable=False)
    data_vencimento = db1.Column(db1.Date)
    pagamento_em_dia = db1.Column(db1.Boolean,default=True)
    ativo = db1.Column(db1.Boolean,default=True)

# -------------------------
# PLANOS
# -------------------------

class Plano(db1.Model):
    __tablename__ = 'planos'

    id = db1.Column(db1.Integer, primary_key=True)

    nome_plano = db1.Column(db1.String(100),nullable=False,unique=True)
    preco = db1.Column(db1.Float, nullable=False)
    descricao = db1.Column(db1.Text)
    ativo = db1.Column(db1.Boolean, default=True)
    data_criacao = db1.Column(db1.DateTime,default=datetime.utcnow)

    # RELACIONAMENTOS
    pacientes = db1.relationship('PacientePlano',backref='plano',lazy=True)

# -------------------------
# VACINAÇÃO
# -------------------------

class Vacinacao(db1.Model):
    __tablename__ = 'vacinacao'

    id = db1.Column(db1.Integer, primary_key=True)
    recepcao_id = db1.Column(db1.Integer,db1.ForeignKey('recepcao.id'),nullable=False)
    vacina = db1.Column(db1.String(100), nullable=False)
    dose = db1.Column(db1.String(30))
    lote = db1.Column(db1.String(50))
    fabricante = db1.Column(db1.String(100))
    data_aplicacao = db1.Column(db1.DateTime,default=datetime.utcnow)
    observacoes = db1.Column(db1.Text)
    responsavel_vacinacao = db1.Column(db1.String(100))
    assinatura = db1.Column(db1.Text)

# -------------------------
# ADMIN
# -------------------------

class BaseAdmin(ModelView):

    def inaccessible_callback(self, name, **kwargs):
        return redirect(url_for("login"))

class AdminRecepcao(BaseAdmin):

    def is_accessible(self):
        return (
            current_user.is_authenticated and
            (current_user.funcao or "").lower()
            in ["recepcionista", "administrador"]
        )

class AdminTriagem(BaseAdmin):

    def is_accessible(self):
        return (
            current_user.is_authenticated and
            (current_user.funcao or "").lower()
            in ["enfermeiro", "administrador"]
        )

class AdminMedico(BaseAdmin):

    def is_accessible(self):
        return (
            current_user.is_authenticated and
            (current_user.funcao or "").lower()
            in ["medico", "administrador"]
        )

class AdminFuncionarios(BaseAdmin):

    def is_accessible(self):
        return (
            current_user.is_authenticated and
            (current_user.funcao or "").lower()
            == "administrador"
        )
