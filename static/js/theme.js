function toggleSenha() {

    const senha = document.getElementById("senha");
    const icon = document.getElementById("toggleSenha");

    if (senha.type === "password") {

        senha.type = "text";

        icon.classList.remove("fa-eye-slash");
        icon.classList.add("fa-eye");

    } else {

        senha.type = "password";

        icon.classList.remove("fa-eye");
        icon.classList.add("fa-eye-slash");
    }
}


function toggleTheme() {
    document.body.classList.toggle("dark");
}