from flask_wtf import FlaskForm

from wtforms import (
    StringField,
    IntegerField,
    FloatField,
    SelectField,
    SubmitField,
    TextAreaField,
    DateField,
    BooleanField,
    PasswordField
)

from wtforms.validators import (
    InputRequired,
    Optional,
    Length,
    NumberRange,
    Email,
    EqualTo
)

import uuid
import qrcode
import base64
from io import BytesIO

# =========================================================
# FUNCIONÁRIOS
# =========================================================

class FuncionarioForm(FlaskForm):

    nome_completo = StringField(
        'Nome completo',
        validators=[
            InputRequired(),
            Length(max=100)
        ]
    )

    usuario = StringField(
        'Usuário',
        validators=[
            InputRequired(),
            Length(max=70)
        ]
    )

    funcao = SelectField(
        'Função',
        choices=[
            ('administrador', 'Administrador'),
            ('recepcionista', 'Recepcionista'),
            ('medico', 'Médico'),
            ('enfermeiro', 'Enfermeiro')
        ],
        validators=[InputRequired()]
    )

    senha = PasswordField(
        'Senha',
        validators=[
            InputRequired(),
            Length(min=6, max=200)
        ]
    )

    confirmar_senha = PasswordField(
        'Confirmar senha',
        validators=[
            InputRequired(),
            EqualTo('senha', message='As senhas devem ser iguais.')
        ]
    )

    sexo = SelectField(
        'Sexo',
        choices=[
            ('', 'Selecione'),
            ('Masculino', 'Masculino'),
            ('Feminino', 'Feminino'),
            ('Outro', 'Outro')
        ],
        validators=[Optional()]
    )

    email = StringField(
        'Email',
        validators=[
            Optional(),
            Email(),
            Length(max=100)
        ]
    )

    telefone = StringField(
        'Telefone',
        validators=[
            Optional(),
            Length(max=20)
        ]
    )

    assinatura = TextAreaField(
        'Assinatura',
        validators=[Optional()]
    )

    submit = SubmitField('Salvar')


# =========================================================
# PACIENTE
# =========================================================

class PacienteForm(FlaskForm):

    nome_completo = StringField(
        'Nome completo',
        validators=[
            InputRequired(),
            Length(max=100)
        ]
    )

    data_nascimento = DateField(
        'Data de nascimento',
        format='%Y-%m-%d',
        validators=[Optional()]
    )

    sexo = SelectField(
        'Sexo',
        choices=[
            ('', 'Selecione'),
            ('Masculino', 'Masculino'),
            ('Feminino', 'Feminino'),
            ('Outro', 'Outro')
        ],
        validators=[Optional()]
    )

    contato = StringField(
        'Contato',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    documento = StringField(
        'Documento',
        validators=[
            Optional(),
            Length(max=30)
        ]
    )

    plano = StringField(
        'Plano',
        validators=[
            Optional(),
            Length(max=50)
        ]
    )

    observacoes_cadastro = TextAreaField(
        'Observações',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    responsavel_cadastro = StringField(
        'Responsável pelo cadastro',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    foto = StringField(
        'Foto',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    email = StringField(
        'Email',
        validators=[
            Optional(),
            Email(),
            Length(max=100)
        ]
    )

    usuario = StringField(
        'Usuário',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    senha = PasswordField(
        'Senha',
        validators=[
            Optional(),
            Length(min=6, max=200)
        ]
    )

    confirmar_senha = PasswordField(
        'Confirmar senha',
        validators=[
            Optional(),
            EqualTo('senha', message='As senhas devem ser iguais.')
        ]
    )

    responsavel = StringField(
        'Responsável',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    assinatura = TextAreaField(
        'Assinatura',
        validators=[Optional()]
    )

    submit = SubmitField('Salvar')


# =========================================================
# RECEPÇÃO
# =========================================================

class RecepcaoForm(FlaskForm):

    paciente_id = SelectField(
        'Paciente',
        coerce=str,
        validators=[InputRequired()]
    )

    urgencia_recepcao = SelectField(
        'Urgência',
        choices=[
            ('', 'Selecione'),
            ('Vermelho', 'Vermelho'),
            ('Laranja', 'Laranja'),
            ('Amarelo', 'Amarelo'),
            ('Verde', 'Verde'),
            ('Azul', 'Azul')
        ],
        validators=[Optional()]
    )

    chamado = BooleanField('Paciente chamado')

    destino = SelectField(
        'Destino',
        choices=[
            ('', 'Selecione'),
            ('Triagem', 'Triagem'),
            ('Consultório', 'Consultório'),
            ('Vacinação', 'Vacinação'),
            ('Emergência', 'Emergência'),
            ('Observação', 'Observação')
        ],
        validators=[Optional()]
    )

    observacoes_recepcao = TextAreaField(
        'Observações',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    responsavel_recepcao = StringField(
        'Responsável',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    fila = StringField(
        'Fila',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    status = SelectField(
        'Status',
        choices=[
            ('Aguardando', 'Aguardando'),
            ('Em atendimento', 'Em atendimento'),
            ('Finalizado', 'Finalizado')
        ],
        validators=[Optional()]
    )

    protocolo = StringField(
        'Protocolo',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    motivo = TextAreaField(
        'Motivo',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    finalizado = BooleanField('Finalizado')

    assinatura1 = TextAreaField(
        'Assinatura',
        validators=[Optional()]
    )

    submit = SubmitField('Salvar')


# =========================================================
# TRIAGEM
# =========================================================

class TriagemForm(FlaskForm):

    recepcao_id = SelectField(
        'Paciente',
        coerce=int,
        validators=[InputRequired()]
    )

    ocupacao = StringField(
        'Ocupação',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    temperatura = StringField(
        'Temperatura',
        validators=[
            Optional(),
            Length(max=20)
        ]
    )

    freq_cardiaca = IntegerField(
        'Frequência cardíaca',
        validators=[Optional()]
    )

    freq_respiratoria = IntegerField(
        'Frequência respiratória',
        validators=[Optional()]
    )

    peso = StringField(
        'Peso',
        validators=[
            Optional(),
            Length(max=20)
        ]
    )

    altura = StringField(
        'Altura',
        validators=[
            Optional(),
            Length(max=20)
        ]
    )

    pressao_arterial = StringField(
        'Pressão arterial',
        validators=[
            Optional(),
            Length(max=20)
        ]
    )

    saturacao = IntegerField(
        'Saturação',
        validators=[
            Optional(),
            NumberRange(min=0, max=100)
        ]
    )

    alergia = StringField(
        'Alergia',
        validators=[
            Optional(),
            Length(max=50)
        ]
    )

    queixa_principal = TextAreaField(
        'Queixa principal',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    doencas_pre_existentes = TextAreaField(
        'Doenças pré-existentes',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    finalizado_triagem = BooleanField('Triagem finalizada')

    responsavel_triagem = StringField(
        'Responsável',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    observacoes_triagem = TextAreaField(
        'Observações',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    tabagista = BooleanField('Tabagista')

    bebida_alcoolica = BooleanField('Bebida alcoólica')

    cirurgia_realizada = TextAreaField(
        'Cirurgias realizadas',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    escala_de_dor = IntegerField(
        'Escala de dor',
        validators=[
            Optional(),
            NumberRange(min=0, max=10)
        ]
    )

    toma_medicacao = TextAreaField(
        'Medicação em uso',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    imc = StringField(
        'IMC',
        validators=[
            Optional(),
            Length(max=20)
        ]
    )

    gestante = BooleanField('Gestante')

    tipo_sanguineo = SelectField(
        'Tipo sanguíneo',
        choices=[
            ('', 'Selecione'),
            ('A+', 'A+'),
            ('A-', 'A-'),
            ('B+', 'B+'),
            ('B-', 'B-'),
            ('AB+', 'AB+'),
            ('AB-', 'AB-'),
            ('O+', 'O+'),
            ('O-', 'O-')
        ],
        validators=[Optional()]
    )

    submit = SubmitField('Salvar')


# =========================================================
# MÉDICO
# =========================================================

class MedicoForm(FlaskForm):

    recepcao_id = SelectField(
        'Paciente',
        coerce=int,
        validators=[InputRequired()]
    )

    diagnostico = TextAreaField(
        'Diagnóstico',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    prescricao = TextAreaField(
        'Prescrição',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    feedback = TextAreaField(
        'Feedback',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    observacoes_medico = TextAreaField(
        'Observações',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    cid = StringField(
        'CID',
        validators=[
            Optional(),
            Length(max=20)
        ]
    )

    finalizado_medico = BooleanField(
        'Atendimento finalizado'
    )

    responsavel_medico = StringField(
        'Responsável',
        validators=[
            Optional(),
            Length(max=100)
        ]
    )

    submit = SubmitField('Salvar')

    def preencher_form(self, recepcao):

        self.recepcao_id.choices = [
            (
                recepcao.id,
                f"{recepcao.id} - {recepcao.paciente.nome_completo}"
            )
        ]

        self.recepcao_id.data = recepcao.id

        if recepcao.medico:

            self.diagnostico.data = recepcao.medico.diagnostico
            self.prescricao.data = recepcao.medico.prescricao
            self.feedback.data = recepcao.medico.feedback
            self.observacoes_medico.data = recepcao.medico.observacoes_medico
            self.cid.data = recepcao.medico.cid
            self.finalizado_medico.data = recepcao.medico.finalizado_medico
            self.responsavel_medico.data = recepcao.medico.responsavel_medico


# =========================================================
# PLANOS
# =========================================================

class PlanoForm(FlaskForm):

    nome_plano = StringField(
        'Nome do plano',
        validators=[
            InputRequired(),
            Length(max=100)
        ]
    )

    preco = FloatField(
        'Preço',
        validators=[
            InputRequired(),
            NumberRange(min=0)
        ]
    )

    descricao = TextAreaField(
        'Descrição',
        validators=[
            Optional(),
            Length(max=5000)
        ]
    )

    ativo = BooleanField('Plano ativo')

    submit = SubmitField('Salvar')


# =========================================================
# PACIENTE PLANO
# =========================================================
class PacientePlanoForm(FlaskForm):

    paciente_id = SelectField('Paciente',coerce=str,validators=[InputRequired()])
    plano_id = SelectField('Plano',coerce=int,validators=[InputRequired()])
    data_inicio = DateField('Data de início',format='%Y-%m-%d',validators=[InputRequired()])
    data_vencimento = DateField('Data de vencimento',format='%Y-%m-%d',validators=[Optional()])
    pagamento_em_dia = BooleanField('Pagamento em dia')
    ativo = BooleanField('Plano ativo')

    submit = SubmitField('Salvar')


# =========================================================
# VACINAÇÃO
# =========================================================
class VacinacaoForm(FlaskForm):

    recepcao_id = SelectField('Paciente',coerce=int,validators=[InputRequired()])
    vacina = StringField('Vacina',validators=[InputRequired(),Length(max=100)])
    dose = StringField('Dose',validators=[Optional(),Length(max=30)])
    lote = StringField('Lote',validators=[Optional(),Length(max=50)])
    fabricante = StringField('Fabricante',validators=[Optional(),Length(max=100)])
    observacoes = TextAreaField('Observações',validators=[Optional(),Length(max=5000)])
    responsavel_vacinacao = StringField('Responsável',validators=[Optional(),Length(max=100)])
    assinatura = TextAreaField('Assinatura',validators=[Optional()])

    submit = SubmitField('Salvar')


# =========================================================
# LOGIN
# =========================================================
class LoginForm(FlaskForm):

    usuario = StringField('Usuário',validators=[InputRequired()])
    senha = PasswordField('Senha',validators=[InputRequired()])

    submit = SubmitField('Entrar')