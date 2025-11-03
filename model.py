from dados1 import db1 
from flask_wtf import FlaskForm
from wtforms.validators import InputRequired
from wtforms import StringField, IntegerField
from flask_login import UserMixin, current_user
from flask_admin.contrib.sqla import ModelView


class luna(db1.Model):
    __tablename__ = 'cu'
    id = db1.Column(db1.Integer, primary_key = True, unique = True, nullable = True)
    nome = db1.Column(db1.String(70), nullable = True)
    idade = db1.Column(db1.Integer, nullable = True)
    sexo = db1.Column(db1.String(1), nullable = True)
    ticket = db1.Column(db1.String(5), nullable = True)
    # classe q representa a tabela do banco de dados dos caras la

class meoewl(luna):
    pass

class luna2(db1.Model):
    __tablename__ = 'cu2'
    id = db1.Column(db1.Integer, primary_key = True, unique = True, nullable = True)
    cardiaco = db1.Column(db1.String(70), nullable = True)
    peso = db1.Column(db1.Integer, nullable = True)
    altura = db1.Column(db1.String(1), nullable = True)
    #classe q respresenta a tabela da triagem nao sei escrever

# essas classe cu e cu2 são pra representar as duas tabela do banco de dados,eu irei ver pra compartilhar o banco de dados
class meowl1(luna2):
    pass

class boing (UserMixin, db1.Model):
    __tablename__ = 'boing'
    id = db1.Column(db1.Integer, primary_key = True, unique = True, nullable = True)
    nome = db1.Column(db1.String(70), nullable = True)
    função = db1.Column(db1.String(15), nullable = True)
# essas classe cu e cu2 são pra representar as duas tabela do banco de dados, dps irei ver pra compartilhar o banco de dados


class lala (ModelView):
    def is_accessible(self):
       return current_user.is_authenticated and current_user.função == "recepção"


class lala2 (ModelView):
    form_widget_args = {'nome':{'readonly': True}, 'idade':{'readonly': True}, 'sexo':{'readonly': True} }
    def is_accessible(self):
        return current_user.is_authenticated and current_user.função == "triagem"

class lala3 (ModelView):
    def is_accessible(self):
       return current_user.is_authenticated and current_user.função == "médico"
    

class login(FlaskForm):
    nome = StringField('nome', validators = [InputRequired('nome necessario')])
    senha = StringField('senha', validators = [InputRequired('nome necessario')])
