from flask import Flask, render_template, redirect, url_for
from dados1 import db1
from model import login, pacientes, admin_user, lala, lala2, pacientes_triagem, lala3, meoewl, meowl1, lala4
from flask_admin import Admin
from flask_admin.contrib.sqla import ModelView
from flask_login import LoginManager, login_user, logout_user, login_required

# oi meus fofos lindos 
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost/enfermagem'

app.config['SECRET_KEY'] = 'cu'
                        #   ↑ essa chave tem q ser mudada dps, não coisei agora pq fiquei com preguiça, mas se 
                        #   mas se quiser alterar, use uma bibloteca q tem no proprio python, acho q se chama hash

db1.init_app(app)

lg = LoginManager()
lg.init_app(app)

cu5 = Admin()
cu5.add_views(lala(pacientes, db1.session)) 
cu5.add_views(lala2(pacientes_triagem, db1.session))
cu5.add_views(lala3(meoewl,  db1.session))
cu5.add_views(lala3(meowl1,  db1.session))
cu5.add_views(lala4(admin_user, db1.session))
cu5.init_app(app)

@lg.user_loader
def loader(id):
    return db1.session.query(admin_user).filter_by(id = id).first()

@app.route('/')
def inicio():
    return 'cu'

# minha mãe falou que eu pareço o meowl vou chorar de felicidade

@app.route('/login', methods = ['GET', 'POST']) 
def ci():
    user = login()
    if user.validate_on_submit():
        lala = db1.session.query(admin_user).filter_by(nome = user.nome.data).first()
        if lala:
            login_user(lala)
            return redirect(url_for('admin.index'))
        else:
            return 'nao achei vc ok'

    return render_template('login.html', form = user)

@app.route('/sair')
@login_required
def sair():
    logout_user()
    return 'tchau'


#I'm #I'm a new soul I came to this strange world hoping
#I could learn a bit bout how to give and take
#But since I came here felt the joy and the fear
#Finding myself making every possible mistake
#La-la-la-la-la-la-la-la


if __name__ == '__main__': # coitadinhos deles, estão sozinho
    app.run(debug=True)
