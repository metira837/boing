from dados1 import db1 
from flask_wtf import FlaskForm
from wtforms.validators import InputRequired
from wtforms import StringField, IntegerField
from flask_login import UserMixin, current_user
from flask_admin.contrib.sqla import ModelView


class pacientes(db1.Model):
    __tablename__ = 'pacientes'
    id = db1.Column(db1.Integer, primary_key = True, unique = True, nullable = True)
    nome = db1.Column(db1.String(70), nullable = True)
    idade = db1.Column(db1.Integer, nullable = True)
    sexo = db1.Column(db1.String(10), nullable = True)
    ticket = db1.Column(db1.String(5), nullable = True)
    documentos = db1.Column(db1.String(20), nullable = True)
    contato = db1.Column(db1.Integer, nullable = True)
    # classe q representa a tabela do banco de dados dos caras la

class meoewl(pacientes):
    pass

class pacientes_triagem(db1.Model):
    __tablename__ = 'pacientes_triagem'
    id = db1.Column(db1.Integer, primary_key = True, unique = True, nullable = True)
    nome = db1.Column(db1.String(70), nullable = True)
    idade = db1.Column(db1.Integer, nullable = True)
    sexo = db1.Column(db1.String(10), nullable = True)
    ticket = db1.Column(db1.String(5), nullable = True)
    documentos = db1.Column(db1.String(20), nullable = True)
    contato = db1.Column(db1.Integer, nullable = True)
    peso = db1.Column(db1.Float, nullable = True)
    altura = db1.Column(db1.Float, nullable = True)
    sexo = db1.Column(db1.String(10), nullable = True)
    temperatura = db1.Column(db1.Float, nullable = True)
    queixa = db1.Column(db1.String(50), nullable = True)
    #classe q respresenta a tabela da triagem nao sei escrever

# essas classe cu e cu2 são pra representar as duas tabela do banco de dados,eu irei ver pra compartilhar o banco de dados
class meowl1(pacientes_triagem):
    pass

class admin_user (UserMixin, db1.Model):
    __tablename__ = 'admin_user'
    id = db1.Column(db1.Integer, primary_key = True, unique = True, nullable = True)
    nome = db1.Column(db1.String(70), nullable = True)
    usuario = db1.Column(db1.String(70), nullable = True)
    função = db1.Column(db1.String(15), nullable = True)
    senha = db1.Column(db1.String(50), nullable = True)
# essas classe cu e cu2 são pra representar as duas tabela do banco de dados, dps irei ver pra compartilhar o banco de dados

class tochorando(ModelView):
    create_template = 'admin/sonic.html'
#   edit_template = 'admin/nomedoarquivo'
#   list_template = 'admin/nomedoarquivo'
   
class lala (tochorando):
    def is_accessible(self):
       return current_user.is_authenticated and current_user.função == "recepção"


class lala2 (tochorando):
    form_widget_args = {'nome':{'readonly': True}, 'idade':{'readonly': True}, 'sexo':{'readonly': True}, 'documentos':{'readonly': True}, 'contato':{'readonly': True} }
    def is_accessible(self):
        return current_user.is_authenticated and current_user.função == "triagem"

class lala3 (tochorando):
    def is_accessible(self):
       return current_user.is_authenticated and current_user.função == "médico"

class lala4 (tochorando):
    def is_accessible(self):
        return current_user.is_authenticated and current_user.função == "tecnico"    

class login(FlaskForm):
    nome = StringField('nome', validators = [InputRequired('nome necessario')])
    senha = StringField('senha', validators = [InputRequired('nome necessario')])
