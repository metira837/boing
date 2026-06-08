# =========================================================
# IMPORTS
# =========================================================
from flask import (
    Flask,
    render_template,
    redirect,
    url_for,
    abort,
    flash,
    request
)
from werkzeug.utils import secure_filename
from flask_socketio import SocketIO, emit

from flask_login import (
    LoginManager,
    login_user,
    logout_user,
    login_required,
    current_user
)

from flask_admin import Admin

from datetime import datetime

from io import BytesIO
import os
import uuid
import qrcode
import base64
import secrets

# =========================================================
# DATABASE / MODELS
# =========================================================
from dados1 import db1

from model import (
    Funcionarios,
    Recepcao,
    Triagem,
    Medico,
    Paciente,

    # IMPORTANTE:
    # Adicione Pacientes no model.py
    # ou remova se não existir
    # Pacientes,

    AdminRecepcao,
    AdminTriagem,
    AdminMedico,
    AdminFuncionarios
)

# =========================================================
# FORMS
# =========================================================
from forms import (
    FuncionarioForm,
    RecepcaoForm,
    TriagemForm,
    MedicoForm,
    LoginForm,
    PacienteForm
)

# =========================================================
# APP
# =========================================================
app = Flask(__name__)

app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///project.db"
app.config["SECRET_KEY"] = secrets.token_hex(32)
app.config["UPLOAD_FOLDER"] = "static/uploads"

db1.init_app(app)

socketio = SocketIO(app,async_mode="threading")

# =========================================================
# DATABASE CREATE
# =========================================================
with app.app_context():
    db1.create_all()

# =========================================================
# LOGIN MANAGER
# =========================================================
login_manager = LoginManager()

login_manager.init_app(app)

login_manager.login_view = "login"

@login_manager.user_loader
def load_user(user_id):

    try:
        return db1.session.get(Funcionarios, user_id)

    except Exception:
        return None

# =========================================================
# FLASK ADMIN
# =========================================================
admin = Admin(app, name="Painel Clínico")

admin.add_view(
    AdminRecepcao(
        Recepcao,
        db1,
        name="Recepção"
    )
)

admin.add_view(
    AdminTriagem(
        Triagem,
        db1,
        name="Triagem"
    )
)

admin.add_view(
    AdminMedico(
        Medico,
        db1,
        name="Médico"
    )
)

admin.add_view(
    AdminFuncionarios(
        Funcionarios,
        db1,
        name="Funcionários"
    )
)

# =========================================================
# HELPERS
# =========================================================
def check_role(*roles):

    return (
        current_user.is_authenticated
        and current_user.funcao
        and current_user.funcao.lower() in [r.lower() for r in roles]
    )

def require_role(*roles):

    if not check_role(*roles):
        abort(403)

# =========================================================
# ASSINATURA
# =========================================================
@app.route("/assinar/<token>")
def assinar(token):

    return render_template(
        "utils/assinatura.html",
        token=token
    )

# =========================================================
# LOGIN
# =========================================================
@app.route("/", methods=["GET", "POST"])
def login():

    form = LoginForm()

    if form.validate_on_submit():

        usuario = form.usuario.data.strip()

        user = Funcionarios.query.filter_by(
            usuario=usuario
        ).first()

        if user and user.check_senha(form.senha.data):

            login_user(user)

            func = (user.funcao or "").strip().lower()

            if func == "administrador":
                return redirect(url_for("admin_dashboard"))

            elif func == "recepcionista":
                return redirect(url_for("recepcao_list"))

            elif func in ["médico", "medico"]:
                return redirect(url_for("dashboard_medico"))

            elif func == "enfermeiro":
                return redirect(url_for("triagem_dashboard"))

            flash("Função inválida.", "warning")

            return redirect(url_for("login"))

        flash("Usuário ou senha incorretos.", "danger")

    return render_template(
        "login.html",
        form=form
    )

# =========================================================
# LOGOUT
# =========================================================
@app.route("/sair")
@login_required
def sair():

    logout_user()

    return redirect(
        url_for("login")
    )

# =========================================================
# ADMIN
# =========================================================
@app.route("/dashboard_admin")
@login_required
def admin_dashboard():

    require_role("administrador")

    dados = Funcionarios.query.all()

    return render_template(
        "admin/dashboard_admin.html",
        dados=dados
    )

# =========================================================
# FUNCIONARIOS
# =========================================================

@app.route("/dashboard_funcionarios")
@login_required
def funcionarios_list():

    require_role("administrador")

    dados = Funcionarios.query.all()

    return render_template(
        "funcionarios/dashboard_funcionarios.html",
        dados=dados
    )

# =========================================================
# NOVO FUNCIONARIO
# =========================================================

@app.route("/funcionario/novo", methods=["GET", "POST"])
@login_required
def funcionario_novo():
    

    require_role("administrador")

    form = FuncionarioForm()

    token = str(uuid.uuid4())

    ip = request.host.split(":")[0]

    link_assinatura = f"http://{ip}:5000/assinar/{token}"

    qr = qrcode.make(link_assinatura)

    buffer = BytesIO()
    qr.save(buffer, format="PNG")

    qr_code = base64.b64encode(buffer.getvalue()).decode()
    qr_code = f"data:image/png;base64,{qr_code}"

    if form.validate_on_submit():

        novo_func = Funcionarios(
            nome_completo=form.nome_completo.data,
            usuario=form.usuario.data,
            funcao=form.funcao.data,
            sexo=form.sexo.data,
            email=form.email.data,
            telefone=form.telefone.data,
            assinatura=form.assinatura.data,
            assinatura_token=token
        )

        novo_func.set_senha(form.senha.data)

        db1.session.add(novo_func)
        db1.session.commit()

        flash(f"Funcionário {novo_func.nome_completo} criado com sucesso!", "success")

        return redirect(url_for("funcionarios_list"))

    return render_template(
        "funcionarios/form.html",
        form=form,
        action="Novo",
        qr_code=qr_code,
        token=token
    )
# =========================================================
# EDITAR FUNCIONARIO
# =========================================================
@app.route("/funcionario/editar/<string:id>", methods=["GET", "POST"])
@login_required
def funcionarios_editar(id):

    require_role("administrador")

    func = Funcionarios.query.get_or_404(id)

    form = FuncionarioForm(obj=func)

    if form.validate_on_submit():

        func.nome_completo = form.nome_completo.data
        func.usuario = form.usuario.data
        func.funcao = form.funcao.data
        func.sexo = form.sexo.data
        func.email = form.email.data
        func.telefone = form.telefone.data
        func.assinatura = form.assinatura.data

        if form.senha.data:
            func.set_senha(form.senha.data)

        db1.session.commit()

        flash(
            "Funcionário atualizado com sucesso!",
            "success"
        )

        return redirect(
            url_for("funcionarios_list")
        )

    return render_template(
        "funcionarios/form.html",
        form=form,
        action="Editar"
    )
# =========================================================
# NOVO PACIENTE
# =========================================================

@app.route(
    "/paciente/novo",
    methods=["GET", "POST"]
)
@login_required
def paciente_novo():

    form = PacienteForm()

    # =====================================================
    # TOKEN
    # =====================================================

    token = str(uuid.uuid4())

    ip = request.host.split(":")[0]

    link_assinatura = (
        f"http://{ip}:5000/assinar/{token}"
    )

    # =====================================================
    # QR CODE
    # =====================================================

    qr = qrcode.make(link_assinatura)

    buffer = BytesIO()

    qr.save(buffer, format="PNG")

    qr_code = base64.b64encode(
        buffer.getvalue()
    ).decode()

    qr_code = (
        f"data:image/png;base64,{qr_code}"
    )

    # =====================================================
    # SUBMIT
    # =====================================================

    if form.validate_on_submit():
 
        foto_path = None

        # =================================================
        # FOTO
        # =================================================

        if form.foto.data:

            arquivo = form.foto.data

            if arquivo.filename != "":

                nome_arquivo = secure_filename(
                    arquivo.filename
                )

                nome_final = (
                    f"{uuid.uuid4()}_"
                    f"{nome_arquivo}"
                )

                caminho = os.path.join(
                    app.config["UPLOAD_FOLDER"],
                    nome_final
                )

                arquivo.save(caminho)

                foto_path = (
                    f"uploads/{nome_final}"
                )

        # =================================================
        # PACIENTE
        # =================================================

        novo = Paciente(
            
            nome_completo =
                form.nome_completo.data,

            data_nascimento =
                form.data_nascimento.data,

            sexo =
                form.sexo.data,

            contato =
                form.contato.data,

            documento =
                form.documento.data,

            plano =
                form.plano.data,

            observacoes_cadastro =
                form.observacoes_cadastro.data,

            email =
                form.email.data,

            usuario =
                form.usuario.data,

            responsavel =
                form.responsavel.data,

            assinatura =
                form.assinatura.data,

            foto =
                foto_path
        )

        # SENHA
        novo.set_senha(
            form.senha.data
        )

        db1.session.add(novo)

        db1.session.commit()

        flash(
            "Paciente criado com sucesso!",
            "success"
        )

        return redirect(
            url_for(
                "dashboard_pacientes"
            )
        )

    return render_template(

        "pacientes/form.html",

        form=form,

        action="Novo",

        qr_code=qr_code,

        token=token
    )

# =========================================================
# EDITAR PACIENTE
# =========================================================

@app.route("/paciente/editar/<int:id>", methods=["GET", "POST"])
@login_required
def paciente_editar(id):

    paciente = Paciente.query.get_or_404(id)

    form = PacienteForm(obj=paciente)

    if form.validate_on_submit():

        paciente.nome_completo = form.nome_completo.data
        paciente.data_nascimento = form.data_nascimento.data
        paciente.sexo = form.sexo.data
        paciente.contato = form.contato.data
        paciente.documento = form.documento.data
        paciente.plano = form.plano.data
        paciente.observacoes_cadastro = form.observacoes_cadastro.data
        paciente.responsavel_cadastro = form.responsavel_cadastro.data
        paciente.email = form.email.data
        paciente.usuario = form.usuario.data
        paciente.responsavel = form.responsavel.data
        paciente.assinatura = form.assinatura.data

        db1.session.commit()

        flash("Paciente atualizado!", "success")

        return redirect(url_for("pacientes_dashboard"))

    return render_template(
        "pacientes/form.html",
        form=form,
        action="Editar"
    )

# =========================================================
# EXCLUIR PACIENTE
# =========================================================

@app.route("/paciente/excluir/<int:id>", methods=["POST"])
@login_required
def paciente_excluir(id):

    paciente = Paciente.query.get_or_404(id)

    db1.session.delete(paciente)
    db1.session.commit()

    flash("Paciente excluído!", "warning")

    return redirect(url_for("pacientes_dashboard"))
# =========================================================
# EXCLUIR FUNCIONARIO
# =========================================================
@app.route("/funcionario/excluir/<string:id>", methods=["POST"])
@login_required
def funcionarios_excluir(id):

    require_role("administrador")

    func = Funcionarios.query.get_or_404(id)

    db1.session.delete(func)

    db1.session.commit()

    flash(
        "Funcionário excluído com sucesso!",
        "warning"
    )

    return redirect(
        url_for("funcionarios_list")
    )

# =========================================================
# RECEPCAO
# =========================================================
@app.route("/dashboard_recepcao")
@login_required
def recepcao_list():

    require_role(
        "recepcionista",
        "administrador"
    )

    dados = (
        Recepcao.query
        .order_by(
            Recepcao.horario_chegada.desc()
        )
        .all()
    )

    return render_template(
        "recepcao/selecionar.html",
        dados=dados
    )

# =========================================================
# NOVO PACIENTE RECEPCAO
# =========================================================
@app.route("/recepcao/selecionar", methods=["GET", "POST"])
@login_required
def recepcao_selecionar():

    require_role("recepcionista", "administrador")

    pacientes = Paciente.query.order_by(Paciente.nome_completo.asc()).all()

    if request.method == "POST":

        paciente_id = request.form.get("paciente_id")

        paciente = Paciente.query.get_or_404(paciente_id)

        novo = Recepcao(

            nome_completo=paciente.nome_completo,
            data_nascimento=paciente.data_nascimento,
            sexo=paciente.sexo,
            contato=paciente.contato,
            Documento=paciente.documento,
            atendimento="Consulta",
            plano=paciente.plano,
            observacoes_recepcao="Atendimento iniciado via paciente cadastrado",
            urgencia_recepcao="Normal",
            responsavel_recepcao=current_user.nome_completo
        )

        db1.session.add(novo)
        db1.session.commit()

        flash("Atendimento iniciado com sucesso!", "success")

        return redirect(url_for("recepcao_selecionar"))

    return render_template(
        "recepcao/form.html",
        pacientes=pacientes
    )
# =========================================================
# TRIAGEM
# =========================================================
@app.route("/triagem")
@login_required
def triagem_dashboard():

    require_role(
        "enfermeiro",
        "administrador"
    )

    pacientes = (
        Recepcao.query
        .outerjoin(Triagem)
        .filter(
            (Triagem.id == None)
            |
            (Triagem.finalizado_triagem == False)
        )
        .order_by(
            Recepcao.horario_chegada.asc()
        )
        .all()
    )

    return render_template(
        "triagem/dashboard_triagem.html",
        pacientes=pacientes
    )

# =========================================================
# NOVA TRIAGEM
# =========================================================
@app.route("/triagem/novo", methods=["GET", "POST"])
@login_required
def triagem_novo():

    require_role(
        "enfermeiro",
        "administrador"
    )

    form = TriagemForm()

    pacientes_disponiveis = (
        Recepcao.query
        .outerjoin(Triagem)
        .filter(
            (Triagem.id == None)
            |
            (Triagem.finalizado_triagem == False)
        )
        .all()
    )

    form.recepcao_id.choices = [
        (
            p.id,
            f"{p.nome_completo} ({p.id})"
        )
        for p in pacientes_disponiveis
    ]

    if form.validate_on_submit():

        triagem = Triagem(

            recepcao_id=form.recepcao_id.data,

            ocupacao=form.ocupacao.data or "",

            temperatura=form.temperatura.data or "",

            freq_cardiaca=form.freq_cardiaca.data,

            freq_respiratoria=form.freq_respiratoria.data,

            peso=form.peso.data or "",

            altura=form.altura.data or "",

            queixa_principal=form.queixa_principal.data or "",

            doencas_pre_existentes=form.doencas_pre_existentes.data or "",

            urgencia_triagem=form.urgencia_triagem.data or "",

            responsavel_triagem=current_user.nome_completo,

            observacoes_triagem=form.observacoes_triagem.data or "",

            pressao_arterial=form.pressao_arterial.data or "",

            alergia=form.alergia.data or "",

            saturacao=form.saturacao.data,

            tabagista=form.tabagista.data or False,

            bebida_alcoolica=form.bebida_alcoolica.data or False,

            cirugia_realizada=form.cirugia_realizada.data or "",

            escala_de_dor=form.escala_de_dor.data,

            toma_medicacao=form.toma_medicacao.data or "",

            horario_de_triagem=datetime.utcnow(),

            finalizado_triagem=True
        )

        try:

            db1.session.add(triagem)

            db1.session.commit()

            flash(
                "Triagem finalizada com sucesso!",
                "success"
            )

            return redirect(
                url_for("triagem_dashboard")
            )

        except Exception as e:

            db1.session.rollback()

            flash(
                f"Erro ao salvar triagem: {e}",
                "danger"
            )

    return render_template(
        "triagem/form.html",
        form=form,
        action="Finalizar"
    )

# =========================================================
# DASHBOARD MEDICO
# =========================================================
@app.route("/dashboard_medico")
@login_required
def dashboard_medico():

    require_role(
        "medico",
        "médico",
        "administrador"
    )

    pacientes_aguardando = (

        Recepcao.query

        .join(Triagem)

        .filter(
            Triagem.finalizado_triagem == True
        )

        .outerjoin(Medico)

        .filter(
            (Medico.id == None)
            |
            (Medico.finalizado_medico == False)
        )

        .order_by(
            Triagem.horario_de_triagem.asc()
        )

        .all()
    )

    ultimos_atendimentos = (

        Medico.query

        .filter(
            Medico.finalizado_medico == True
        )

        .order_by(
            Medico.horario_de_finalizacao.desc()
        )

        .limit(5)

        .all()
    )

    atendimentos_hoje = (

        Medico.query

        .filter(
            Medico.horario_de_finalizacao >= datetime.utcnow().replace(
                hour=0,
                minute=0,
                second=0
            )
        )

        .count()
    )

    return render_template(
        "medico/dashboard_medico.html",

        pacientes_aguardando=pacientes_aguardando,

        ultimos_atendimentos=ultimos_atendimentos,

        atendimentos_hoje=atendimentos_hoje
    )

# =========================================================
# ATENDIMENTO MEDICO
# =========================================================
@app.route('/atender_paciente/<string:paciente_id>', methods=['GET', 'POST'])
@login_required
def atender_paciente(paciente_id):

    require_role(
        "medico",
        "médico",
        "administrador"
    )

    paciente = Recepcao.query.get_or_404(
        paciente_id
    )

    form = MedicoForm()

    form.preencher_form(paciente)

    if form.validate_on_submit():

        if not paciente.medico:

            atendimento = Medico(

                recepcao_id=paciente.id,

                feedback=form.feedback.data or '',

                diagnostico=form.diagnostico.data or '',

                prescricao=form.prescricao.data or '',

                finalizado_medico=True,

                responsavel_medico=current_user.nome_completo,

                observacoes_medico=form.observacoes_medico.data or '',

                horario_de_finalizacao=datetime.utcnow()
            )

            db1.session.add(atendimento)

        else:

            atendimento = paciente.medico

            atendimento.feedback = form.feedback.data or ''

            atendimento.diagnostico = form.diagnostico.data or ''

            atendimento.prescricao = form.prescricao.data or ''

            atendimento.finalizado_medico = True

            atendimento.responsavel_medico = current_user.nome_completo

            atendimento.observacoes_medico = form.observacoes_medico.data or ''

            atendimento.horario_de_finalizacao = datetime.utcnow()

        db1.session.commit()

        flash(
            f"Atendimento do paciente {paciente.nome_completo} finalizado!",
            "success"
        )

        return redirect(
            url_for("dashboard_medico")
        )

    return render_template(
        "medico/form.html",
        form=form,
        paciente=paciente,
        action="Finalizar"
    )

# =========================================================
# PAINEL SENHA
# =========================================================
@app.route("/painel_senha")
@login_required
def painel_senha():

    require_role("administrador")

    pacientes = (

        Recepcao.query

        .filter(
            Recepcao.chamado == True
        )

        .order_by(
            Recepcao.horario_chamada.desc()
        )

        .all()
    )

    return render_template(
        "utils/painel_senha.html",
        pacientes=pacientes
    )

# =========================================================
# CHAMAR PACIENTE
# =========================================================
@app.route("/chamar_paciente/<paciente_id>/<destino>", methods=["POST"])
@login_required
def chamar_paciente(paciente_id, destino):

    require_role(
        "enfermeiro",
        "administrador",
        "medico",
        "médico"
    )

    paciente = Recepcao.query.get_or_404(
        paciente_id
    )

    paciente.chamado = True

    paciente.destino = destino

    paciente.horario_chamada = datetime.utcnow()

    db1.session.commit()

    flash(
        f"Paciente {paciente.nome_completo} chamado para {destino}!",
        "success"
    )

    if destino.lower() == "triagem":
        return redirect(
            url_for("triagem_dashboard")
        )

    if destino.lower() == "consulta":
        return redirect(
            url_for("dashboard_medico")
        )

    return redirect(
        request.referrer or url_for("recepcao_list")
    )

# =========================================================
# SOCKET
# =========================================================
@socketio.on("assinatura_finalizada")
def assinatura_finalizada(data):

    token = data.get("token")

    imagem = data.get("imagem")

    emit(
        "assinatura_recebida",
        {
            "token": token,
            "imagem": imagem
        },
        broadcast=True
    )

# =========================================================
# GUIA
# =========================================================
@app.route("/guia")
@login_required
def guia():

    return render_template(
        "utils/guia.html"
    )
# =========================================================
# DASHBOARD PACIENTES
# =========================================================
@app.route(
    "/dashboard_pacientes",
    endpoint="dashboard_pacientes"
)
@login_required
def dashboard_pacientes():
    
    require_role("administrador")

    dados = (
    Paciente.query
    .order_by(
        Paciente.nome_completo.asc()
    )
    .all()
)

    return render_template(
      "pacientes/dashboard_pacientes.html",
        dados=dados
    )
# =========================================================
# RUN
# =========================================================
if __name__ == "__main__":

    socketio.run(
        app,
        host="0.0.0.0",
        port=5000,
        debug=True
    )
