--
-- PostgreSQL database dump
--

\restrict dVVwXAXuCwgeKxG3LLqBnrI2FPpiUp9d90mVIwb3ljHBdhuSffrCLyVKyjOvQM0

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2025-12-01 18:34:57 -03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 255 (class 1255 OID 16421)
-- Name: atribuir_ticket(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.atribuir_ticket() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- só gera ticket se não tiver sido informado manualmente
    IF NEW.ticket IS NULL THEN
        NEW.ticket := gerar_ticket();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.atribuir_ticket() OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 16420)
-- Name: gerar_ticket(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gerar_ticket() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    alfabeto TEXT[] := ARRAY[
        'A','B','C','D','E','F','G','H','I','J','K','L','M',
        'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'
    ];
    letra TEXT;
    numero INT;
    novo_ticket TEXT;
BEGIN
    LOOP
        letra := alfabeto[ceil(random() * array_length(alfabeto, 1))];
        numero := floor(random() * 100);
        novo_ticket := letra || lpad(numero::TEXT, 2, '0');

        -- 👇 AQUI ESTÁ A CORREÇÃO
        IF NOT EXISTS (SELECT 1 FROM pacientes WHERE ticket = novo_ticket) THEN
            RETURN novo_ticket;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION public.gerar_ticket() OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 16433)
-- Name: inserir_na_triagem(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.inserir_na_triagem() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO pacientes_triagem (
        nome,
        idade,
        sexo,
        ticket,
        documentos,
        contato,
        data,
        atendimento
    ) VALUES (
        NEW.nome,
        NEW.idade,
        NEW.sexo,
        NEW.ticket,
        NEW.documentos,
        NEW.contato,
        NEW.data,
        NEW.atendimento
    );

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.inserir_na_triagem() OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 24908)
-- Name: move_para_medico(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.move_para_medico() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NEW.finalizado = true
OR NEW.observacao IS NOT NULL
OR NEW.toma_medicacao IS NOT NULL THEN
IF NOT EXISTS (
SELECT 1
FROM pacientes_medico
WHERE cpf = NEW.cpf
) THEN
INSERT INTO pacientes_medico(
nome,
data_nascimento,
sexo,
ticket,
alergias,
pressao,
altura,
temperatura,
queixa,
peso,
cpf,
contato,
doenças,
ocupação,
respiratoria,
pressao_arterial,
enderenço,
responsavel,
diagnostico,
prescrição,
horario_de_finalizacao,
feedback,
finalizado,
cardiaca,
cirugia_realizada,
escala_de_dor,
bebida_alcoolica,
tabagista,
atendimento,
saturação,
toma_medicacao,
observacao
) VALUES (
NEW.nome,
NEW.data_nascimento,
NEW.sexo,
NEW.ticket,
NEW.alergias,
NEW.pressao,
NEW.altura,
NEW.temperatura,
NEW.queixa,
NEW.peso,
NEW.cpf,
NEW.contato,
NEW.doenças,
NEW.ocupação,
NEW.respiratoria,
NEW.pressao_arterial,
NEW.enderenço,
NEW.responsavel,
NULL,
NULL,
NULL,
NULL,
NEW.finalizado,
NEW.cárdiaca,
NEW.cirugia_realizada,
NEW.escala_de_dor,
NEW.bebida_alcoolica,
NEW.tabagista,
NEW.atendimento,
NEW.saturação,
NEW.toma_medicacao,
NEW.observacao
);
END IF;
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.move_para_medico() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 16402)
-- Name: admin_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_user (
    id integer CONSTRAINT admin_id_not_null NOT NULL,
    nome character varying(20) CONSTRAINT admin_nome_not_null NOT NULL,
    "função" character varying(10) CONSTRAINT "admin_função_not_null" NOT NULL,
    senha character varying(50) CONSTRAINT admin_senha_not_null NOT NULL,
    usuario character varying(50),
    idade smallint,
    sexo character varying(10),
    contato character varying(10)
);


ALTER TABLE public.admin_user OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16401)
-- Name: admin_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_id_seq OWNER TO postgres;

--
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 220
-- Name: admin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_id_seq OWNED BY public.admin_user.id;


--
-- TOC entry 237 (class 1259 OID 16534)
-- Name: auth_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16533)
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_group ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 239 (class 1259 OID 16544)
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16543)
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_group_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 16524)
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16523)
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_permission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 241 (class 1259 OID 16553)
-- Name: auth_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE public.auth_user OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16572)
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user_groups (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_groups OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 16571)
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_user_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 240 (class 1259 OID 16552)
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 245 (class 1259 OID 16581)
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user_user_permissions (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_permissions OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 16580)
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_user_user_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 247 (class 1259 OID 16642)
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 16641)
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.django_admin_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 16512)
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16511)
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 16500)
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16499)
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 248 (class 1259 OID 16682)
-- Name: django_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16459)
-- Name: funcionarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.funcionarios (
    id integer NOT NULL,
    nome_completo character varying(100) NOT NULL,
    usuario character varying(70) NOT NULL,
    funcao character varying(30) NOT NULL,
    senha_hash character varying(200) NOT NULL,
    data_nascimento date,
    sexo character varying(15),
    contato character varying(100)
);


ALTER TABLE public.funcionarios OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16458)
-- Name: funcionarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.funcionarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.funcionarios_id_seq OWNER TO postgres;

--
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 225
-- Name: funcionarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.funcionarios_id_seq OWNED BY public.funcionarios.id;


--
-- TOC entry 219 (class 1259 OID 16390)
-- Name: pacientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pacientes (
    nome character varying(100) NOT NULL,
    sexo character varying(10) NOT NULL,
    ticket character varying(5) NOT NULL,
    contato smallint,
    id integer NOT NULL,
    atendimento character(8),
    planos character varying(10),
    urgencia character(1),
    data_nascimento timestamp without time zone,
    cpf character(15),
    horario_de_chegada timestamp without time zone,
    "observeção" character varying(100),
    resposavel character varying(100),
    "enderenço" character varying(50)
);


ALTER TABLE public.pacientes OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16445)
-- Name: pacientes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pacientes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pacientes_id_seq OWNER TO postgres;

--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 224
-- Name: pacientes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pacientes_id_seq OWNED BY public.pacientes.id;


--
-- TOC entry 254 (class 1259 OID 24893)
-- Name: pacientes_medico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pacientes_medico (
    nome character varying(100),
    data_nascimento timestamp without time zone,
    sexo character varying(10),
    ticket character(3),
    alergias character varying(20),
    pressao real,
    altura real,
    temperatura real,
    queixa character varying(50),
    peso real,
    cpf character varying(15),
    contato smallint,
    id integer NOT NULL,
    "doenças" character varying(50),
    "ocupação" character varying(50),
    respiratoria smallint,
    pressao_arterial character(10),
    "enderenço" character varying(50),
    responsavel character varying(100),
    diagnostico character varying(100),
    "prescrição" character varying(100),
    horario_de_finalizacao timestamp without time zone,
    feedback character varying(100),
    finalizado boolean,
    cardiaca smallint,
    cirugia_realizada character varying(50),
    escala_de_dor smallint,
    bebida_alcoolica boolean,
    tabagista boolean,
    atendimento character varying(20),
    "saturação" smallint,
    toma_medicacao character varying(50),
    observacao character varying(50)
);


ALTER TABLE public.pacientes_medico OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 24892)
-- Name: pacientes_medico_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pacientes_medico_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pacientes_medico_id_seq OWNER TO postgres;

--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 253
-- Name: pacientes_medico_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pacientes_medico_id_seq OWNED BY public.pacientes_medico.id;


--
-- TOC entry 222 (class 1259 OID 16417)
-- Name: pacientes_triagem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pacientes_triagem (
    nome character varying(100),
    idade integer,
    sexo character varying(10),
    ticket character(3),
    alergias character varying(20),
    pressao real,
    altura real,
    temperatura real,
    queixa character varying(50),
    peso real,
    contato smallint,
    id integer NOT NULL,
    "doenças" character varying(30),
    "ocupação" character varying(20),
    respiratoria smallint,
    "cardíaca" smallint,
    pressao_arterial character(8),
    atendimento character varying(20),
    "enderenço" character varying(50),
    "saturação" smallint,
    perigo smallint,
    tabagista boolean,
    bebida_alcoolica boolean,
    cirugia_realizada character varying(50),
    toma_medicacao character varying(50),
    observacao character varying(100),
    horario_da_triagem timestamp without time zone,
    finalizado boolean,
    cpf smallint,
    data_nascimento timestamp without time zone,
    responsavel character varying(50),
    escala_de_dor smallint
);


ALTER TABLE public.pacientes_triagem OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16436)
-- Name: pacientes_triagem_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pacientes_triagem_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pacientes_triagem_id_seq OWNER TO postgres;

--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 223
-- Name: pacientes_triagem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pacientes_triagem_id_seq OWNED BY public.pacientes_triagem.id;


--
-- TOC entry 250 (class 1259 OID 16699)
-- Name: polls_pacientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.polls_pacientes (
    id bigint NOT NULL,
    nome character varying(20) NOT NULL,
    idade integer NOT NULL,
    ticket character varying DEFAULT 'atribuir_ticket()'::character varying NOT NULL,
    documentos character varying(13) NOT NULL,
    contato integer NOT NULL,
    data date NOT NULL,
    data_nascimento integer NOT NULL,
    atendimento character varying(8) NOT NULL
);


ALTER TABLE public.polls_pacientes OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 16698)
-- Name: polls_pacientes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.polls_pacientes ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.polls_pacientes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 252 (class 1259 OID 16717)
-- Name: polls_pacientes_triagem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.polls_pacientes_triagem (
    id bigint NOT NULL,
    nome character varying(20) NOT NULL,
    idade integer NOT NULL,
    ticket character varying NOT NULL,
    documentos character varying(13) NOT NULL,
    contato integer NOT NULL,
    data date NOT NULL,
    data_nascimento integer NOT NULL,
    atendimento character varying(8) NOT NULL,
    "ocupação" character varying NOT NULL,
    "enderenço" integer NOT NULL,
    peso double precision NOT NULL,
    respiratoria integer NOT NULL,
    "saturação" integer NOT NULL,
    pressao_arterial integer NOT NULL,
    altura double precision NOT NULL,
    queixa character varying(50) NOT NULL,
    cardiaca integer NOT NULL,
    temperatura double precision NOT NULL,
    "doenças" character varying(50) NOT NULL
);


ALTER TABLE public.polls_pacientes_triagem OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 16716)
-- Name: polls_pacientes_triagem_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.polls_pacientes_triagem ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.polls_pacientes_triagem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 227 (class 1259 OID 16474)
-- Name: recepcao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recepcao (
    id character varying(5) NOT NULL,
    nome_completo character varying(100) NOT NULL,
    data_nascimento date,
    sexo character varying(15),
    contato character varying(100),
    documento character varying(30),
    atendimento character varying(50),
    plano character varying(50),
    horario_chegada timestamp without time zone
);


ALTER TABLE public.recepcao OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16482)
-- Name: triagem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.triagem (
    id integer NOT NULL,
    recepcao_id character varying(5) NOT NULL,
    ocupacao character varying(100),
    temperatura character varying(20),
    freq_cardiaca integer,
    freq_respiratoria integer,
    peso character varying(20),
    altura character varying(20),
    queixa_principal text,
    doencas_pre_existentes text,
    urgencia character varying(50),
    horario timestamp without time zone,
    diagnostico text,
    prescricao text,
    finalizado boolean,
    data_finalizacao timestamp without time zone,
    responsavel character varying(100),
    observacoes text,
    pressao_arterial integer,
    alergia character varying(50),
    "saturação" integer
);


ALTER TABLE public.triagem OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16481)
-- Name: triagem_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.triagem_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.triagem_id_seq OWNER TO postgres;

--
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 228
-- Name: triagem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.triagem_id_seq OWNED BY public.triagem.id;


--
-- TOC entry 3382 (class 2604 OID 16405)
-- Name: admin_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_user ALTER COLUMN id SET DEFAULT nextval('public.admin_id_seq'::regclass);


--
-- TOC entry 3384 (class 2604 OID 16462)
-- Name: funcionarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios ALTER COLUMN id SET DEFAULT nextval('public.funcionarios_id_seq'::regclass);


--
-- TOC entry 3381 (class 2604 OID 16446)
-- Name: pacientes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes ALTER COLUMN id SET DEFAULT nextval('public.pacientes_id_seq'::regclass);


--
-- TOC entry 3387 (class 2604 OID 24896)
-- Name: pacientes_medico id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes_medico ALTER COLUMN id SET DEFAULT nextval('public.pacientes_medico_id_seq'::regclass);


--
-- TOC entry 3383 (class 2604 OID 16437)
-- Name: pacientes_triagem id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes_triagem ALTER COLUMN id SET DEFAULT nextval('public.pacientes_triagem_id_seq'::regclass);


--
-- TOC entry 3385 (class 2604 OID 16485)
-- Name: triagem id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triagem ALTER COLUMN id SET DEFAULT nextval('public.triagem_id_seq'::regclass);


--
-- TOC entry 3621 (class 0 OID 16402)
-- Dependencies: 221
-- Data for Name: admin_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_user (id, nome, "função", senha, usuario, idade, sexo, contato) FROM stdin;
1	tux	tecnico	cu12	tux	\N	\N	\N
4	sonic	médico	cu123	sonic	\N	\N	\N
5	tonight	triagem	cu67	tonight	\N	\N	\N
6	goku	triagem	goku123	son goku	\N	\N	\N
\.


--
-- TOC entry 3637 (class 0 OID 16534)
-- Dependencies: 237
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- TOC entry 3639 (class 0 OID 16544)
-- Dependencies: 239
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- TOC entry 3635 (class 0 OID 16524)
-- Dependencies: 235
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can view log entry	1	view_logentry
5	Can add permission	2	add_permission
6	Can change permission	2	change_permission
7	Can delete permission	2	delete_permission
8	Can view permission	2	view_permission
9	Can add group	3	add_group
10	Can change group	3	change_group
11	Can delete group	3	delete_group
12	Can view group	3	view_group
13	Can add user	4	add_user
14	Can change user	4	change_user
15	Can delete user	4	delete_user
16	Can view user	4	view_user
17	Can add content type	5	add_contenttype
18	Can change content type	5	change_contenttype
19	Can delete content type	5	delete_contenttype
20	Can view content type	5	view_contenttype
21	Can add session	6	add_session
22	Can change session	6	change_session
23	Can delete session	6	delete_session
24	Can view session	6	view_session
25	Can add pacientes	7	add_pacientes
26	Can change pacientes	7	change_pacientes
27	Can delete pacientes	7	delete_pacientes
28	Can view pacientes	7	view_pacientes
29	Can add pacientes_triagem	8	add_pacientes_triagem
30	Can change pacientes_triagem	8	change_pacientes_triagem
31	Can delete pacientes_triagem	8	delete_pacientes_triagem
32	Can view pacientes_triagem	8	view_pacientes_triagem
\.


--
-- TOC entry 3641 (class 0 OID 16553)
-- Dependencies: 241
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM stdin;
1	pbkdf2_sha256$1000000$6EhaFjfJRZrgRDLTAFxQ8e$NhvwapHbhuYbSvdOYjbRvXHQ6Jv3Lo1so4LH+7MMrWk=	2025-12-01 07:06:11.95616-03	t	tux			tomiokatomiokaoff@gmail.com	t	t	2025-11-30 19:15:34.756496-03
\.


--
-- TOC entry 3643 (class 0 OID 16572)
-- Dependencies: 243
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- TOC entry 3645 (class 0 OID 16581)
-- Dependencies: 245
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- TOC entry 3647 (class 0 OID 16642)
-- Dependencies: 247
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
1	2025-11-30 19:24:18.841757-03	1	pedro	1	[{"added": {}}]	8	1
2	2025-11-30 19:26:11.686717-03	1	pedro	1	[{"added": {}}]	7	1
3	2025-11-30 21:48:03.515966-03	18	no cu nao	1	[{"added": {}}]	7	1
4	2025-11-30 21:48:24.010212-03	18	no cu nao	2	[{"changed": {"fields": ["Data", "Atendimento"]}}]	7	1
5	2025-11-30 21:49:40.251448-03	19	chupa meu cu	1	[{"added": {}}]	7	1
6	2025-12-01 00:00:15.080714-03	24	chupameucuzinho	1	[{"added": {}}]	7	1
\.


--
-- TOC entry 3633 (class 0 OID 16512)
-- Dependencies: 233
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	admin	logentry
2	auth	permission
3	auth	group
4	auth	user
5	contenttypes	contenttype
6	sessions	session
7	polls	pacientes
8	polls	pacientes_triagem
\.


--
-- TOC entry 3631 (class 0 OID 16500)
-- Dependencies: 231
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2025-11-29 14:52:38.708096-03
2	auth	0001_initial	2025-11-29 14:52:38.819538-03
3	admin	0001_initial	2025-11-29 14:52:38.857258-03
4	admin	0002_logentry_remove_auto_add	2025-11-29 14:52:38.885906-03
5	admin	0003_logentry_add_action_flag_choices	2025-11-29 14:52:38.920749-03
6	contenttypes	0002_remove_content_type_name	2025-11-29 14:52:38.976787-03
7	auth	0002_alter_permission_name_max_length	2025-11-29 14:52:39.002797-03
8	auth	0003_alter_user_email_max_length	2025-11-29 14:52:39.033268-03
9	auth	0004_alter_user_username_opts	2025-11-29 14:52:39.063205-03
10	auth	0005_alter_user_last_login_null	2025-11-29 14:52:39.089967-03
11	auth	0006_require_contenttypes_0002	2025-11-29 14:52:39.096204-03
12	auth	0007_alter_validators_add_error_messages	2025-11-29 14:52:39.127859-03
13	auth	0008_alter_user_username_max_length	2025-11-29 14:52:39.160904-03
14	auth	0009_alter_user_last_name_max_length	2025-11-29 14:52:39.191349-03
15	auth	0010_alter_group_name_max_length	2025-11-29 14:52:39.218356-03
16	auth	0011_update_proxy_permissions	2025-11-29 14:52:39.246345-03
17	auth	0012_alter_user_first_name_max_length	2025-11-29 14:52:39.273945-03
18	sessions	0001_initial	2025-11-29 14:52:39.299465-03
19	polls	0001_initial	2025-11-30 19:14:29.751808-03
\.


--
-- TOC entry 3648 (class 0 OID 16682)
-- Dependencies: 248
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
jgn0kp573uz8ev0kc1sd02b4h493qyit	.eJxVjEEOwiAQRe_C2pAwlGlx6d4zkAFmpGogKe3KeHdt0oVu_3vvv1SgbS1h67yEOauzMur0u0VKD647yHeqt6ZTq-syR70r-qBdX1vm5-Vw_w4K9fKtLeLgR8PGRI9OJkZHA1rwAsIsnKwjcQ4sZBDveXSYiCVNgD5bZPX-ANNYN_0:1vQ0nL:9aB4829FdVdyp9Cp006jvQoH8FLR9_UH4KrROOM5114	2025-12-15 07:06:11.963229-03
\.


--
-- TOC entry 3626 (class 0 OID 16459)
-- Dependencies: 226
-- Data for Name: funcionarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.funcionarios (id, nome_completo, usuario, funcao, senha_hash, data_nascimento, sexo, contato) FROM stdin;
\.


--
-- TOC entry 3619 (class 0 OID 16390)
-- Dependencies: 219
-- Data for Name: pacientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pacientes (nome, sexo, ticket, contato, id, atendimento, planos, urgencia, data_nascimento, cpf, horario_de_chegada, "observeção", resposavel, "enderenço") FROM stdin;
Murilo The Greates	Masculino	N02	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N
asnnjsad	Masculino	O14	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N
23ii9	Masculino	M77	12321	3	\N	\N	\N	\N	\N	\N	\N	\N	\N
pedro	Masculino	U76	2356	4	\N	\N	\N	\N	\N	\N	\N	\N	\N
cu	feminino	J25	21321	5	\N	\N	\N	\N	\N	\N	\N	\N	\N
pedro	feminino	X81	\N	6	\N	\N	\N	\N	\N	\N	\N	\N	\N
aimeucuzinho	M	F06	\N	7	\N	\N	\N	\N	\N	\N	\N	\N	\N
liri larila	masculino	R61	1321	8	\N	\N	\N	\N	\N	\N	\N	\N	\N
no cu nao	masculino	True	2322	18	sus     	\N	\N	\N	\N	\N	\N	\N	\N
chupa meu cu	masculino	True	4123	19	sus     	\N	\N	\N	\N	\N	\N	\N	\N
chupameucuzinho	masculino	N59	12	24	SUS     	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3654 (class 0 OID 24893)
-- Dependencies: 254
-- Data for Name: pacientes_medico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pacientes_medico (nome, data_nascimento, sexo, ticket, alergias, pressao, altura, temperatura, queixa, peso, cpf, contato, id, "doenças", "ocupação", respiratoria, pressao_arterial, "enderenço", responsavel, diagnostico, "prescrição", horario_de_finalizacao, feedback, finalizado, cardiaca, cirugia_realizada, escala_de_dor, bebida_alcoolica, tabagista, atendimento, "saturação", toma_medicacao, observacao) FROM stdin;
\.


--
-- TOC entry 3622 (class 0 OID 16417)
-- Dependencies: 222
-- Data for Name: pacientes_triagem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pacientes_triagem (nome, idade, sexo, ticket, alergias, pressao, altura, temperatura, queixa, peso, contato, id, "doenças", "ocupação", respiratoria, "cardíaca", pressao_arterial, atendimento, "enderenço", "saturação", perigo, tabagista, bebida_alcoolica, cirugia_realizada, toma_medicacao, observacao, horario_da_triagem, finalizado, cpf, data_nascimento, responsavel, escala_de_dor) FROM stdin;
aimeucuzinho	\N	M	F06	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
aicuzinho	\N	masculino	R61	\N	\N	\N	\N	\N	\N	1321	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
chupameucuzinho	12	masculino	N59	\N	\N	\N	\N	\N	\N	12	6	\N	\N	\N	\N	\N	SUS	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
chupameucuzinho	12	masculino	N59	\N	\N	\N	\N	\N	\N	12	7	\N	\N	\N	\N	\N	SUS	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3650 (class 0 OID 16699)
-- Dependencies: 250
-- Data for Name: polls_pacientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.polls_pacientes (id, nome, idade, ticket, documentos, contato, data, data_nascimento, atendimento) FROM stdin;
1	pedro	12	True	2113	13231	2025-11-30	23	SUS
\.


--
-- TOC entry 3652 (class 0 OID 16717)
-- Dependencies: 252
-- Data for Name: polls_pacientes_triagem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.polls_pacientes_triagem (id, nome, idade, ticket, documentos, contato, data, data_nascimento, atendimento, "ocupação", "enderenço", peso, respiratoria, "saturação", pressao_arterial, altura, queixa, cardiaca, temperatura, "doenças") FROM stdin;
1	pedro	12	21	21313	23141	2025-11-30	12	SUS	trabalho	231	70	23	32	21	1.79	aiaiai	21	12	nao
\.


--
-- TOC entry 3627 (class 0 OID 16474)
-- Dependencies: 227
-- Data for Name: recepcao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recepcao (id, nome_completo, data_nascimento, sexo, contato, documento, atendimento, plano, horario_chegada) FROM stdin;
\.


--
-- TOC entry 3629 (class 0 OID 16482)
-- Dependencies: 229
-- Data for Name: triagem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.triagem (id, recepcao_id, ocupacao, temperatura, freq_cardiaca, freq_respiratoria, peso, altura, queixa_principal, doencas_pre_existentes, urgencia, horario, diagnostico, prescricao, finalizado, data_finalizacao, responsavel, observacoes, pressao_arterial, alergia, "saturação") FROM stdin;
\.


--
-- TOC entry 3666 (class 0 OID 0)
-- Dependencies: 220
-- Name: admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_id_seq', 6, true);


--
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 236
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- TOC entry 3668 (class 0 OID 0)
-- Dependencies: 238
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 234
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 32, true);


--
-- TOC entry 3670 (class 0 OID 0)
-- Dependencies: 242
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_user_groups_id_seq', 1, false);


--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 240
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_user_id_seq', 1, true);


--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 244
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_user_user_permissions_id_seq', 1, false);


--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 246
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 6, true);


--
-- TOC entry 3674 (class 0 OID 0)
-- Dependencies: 232
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 8, true);


--
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 230
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 19, true);


--
-- TOC entry 3676 (class 0 OID 0)
-- Dependencies: 225
-- Name: funcionarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.funcionarios_id_seq', 1, false);


--
-- TOC entry 3677 (class 0 OID 0)
-- Dependencies: 224
-- Name: pacientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pacientes_id_seq', 24, true);


--
-- TOC entry 3678 (class 0 OID 0)
-- Dependencies: 253
-- Name: pacientes_medico_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pacientes_medico_id_seq', 1, false);


--
-- TOC entry 3679 (class 0 OID 0)
-- Dependencies: 223
-- Name: pacientes_triagem_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pacientes_triagem_id_seq', 7, true);


--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 249
-- Name: polls_pacientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.polls_pacientes_id_seq', 1, true);


--
-- TOC entry 3681 (class 0 OID 0)
-- Dependencies: 251
-- Name: polls_pacientes_triagem_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.polls_pacientes_triagem_id_seq', 1, true);


--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 228
-- Name: triagem_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.triagem_id_seq', 1, false);


--
-- TOC entry 3392 (class 2606 OID 16411)
-- Name: admin_user admin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_user
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id);


--
-- TOC entry 3418 (class 2606 OID 16678)
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- TOC entry 3423 (class 2606 OID 16599)
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- TOC entry 3426 (class 2606 OID 16551)
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 3420 (class 2606 OID 16540)
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- TOC entry 3413 (class 2606 OID 16590)
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- TOC entry 3415 (class 2606 OID 16532)
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 3434 (class 2606 OID 16579)
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 3437 (class 2606 OID 16614)
-- Name: auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- TOC entry 3428 (class 2606 OID 16568)
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3440 (class 2606 OID 16588)
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 3443 (class 2606 OID 16628)
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- TOC entry 3431 (class 2606 OID 16671)
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- TOC entry 3446 (class 2606 OID 16655)
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- TOC entry 3408 (class 2606 OID 16522)
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- TOC entry 3410 (class 2606 OID 16520)
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- TOC entry 3406 (class 2606 OID 16510)
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 3450 (class 2606 OID 16691)
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- TOC entry 3396 (class 2606 OID 16471)
-- Name: funcionarios funcionarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_pkey PRIMARY KEY (id);


--
-- TOC entry 3398 (class 2606 OID 16473)
-- Name: funcionarios funcionarios_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_usuario_key UNIQUE (usuario);


--
-- TOC entry 3457 (class 2606 OID 24899)
-- Name: pacientes_medico pacientes_medico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes_medico
    ADD CONSTRAINT pacientes_medico_pkey PRIMARY KEY (id);


--
-- TOC entry 3390 (class 2606 OID 16449)
-- Name: pacientes pacientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes
    ADD CONSTRAINT pacientes_pkey PRIMARY KEY (id);


--
-- TOC entry 3394 (class 2606 OID 16440)
-- Name: pacientes_triagem pacientes_triagem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes_triagem
    ADD CONSTRAINT pacientes_triagem_pkey PRIMARY KEY (id);


--
-- TOC entry 3453 (class 2606 OID 16715)
-- Name: polls_pacientes polls_pacientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polls_pacientes
    ADD CONSTRAINT polls_pacientes_pkey PRIMARY KEY (id);


--
-- TOC entry 3455 (class 2606 OID 16743)
-- Name: polls_pacientes_triagem polls_pacientes_triagem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polls_pacientes_triagem
    ADD CONSTRAINT polls_pacientes_triagem_pkey PRIMARY KEY (id);


--
-- TOC entry 3400 (class 2606 OID 16480)
-- Name: recepcao recepcao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recepcao
    ADD CONSTRAINT recepcao_pkey PRIMARY KEY (id);


--
-- TOC entry 3402 (class 2606 OID 16491)
-- Name: triagem triagem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triagem
    ADD CONSTRAINT triagem_pkey PRIMARY KEY (id);


--
-- TOC entry 3404 (class 2606 OID 16493)
-- Name: triagem triagem_recepcao_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triagem
    ADD CONSTRAINT triagem_recepcao_id_key UNIQUE (recepcao_id);


--
-- TOC entry 3416 (class 1259 OID 16679)
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- TOC entry 3421 (class 1259 OID 16610)
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- TOC entry 3424 (class 1259 OID 16611)
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- TOC entry 3411 (class 1259 OID 16596)
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- TOC entry 3432 (class 1259 OID 16626)
-- Name: auth_user_groups_group_id_97559544; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);


--
-- TOC entry 3435 (class 1259 OID 16625)
-- Name: auth_user_groups_user_id_6a12ed8b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);


--
-- TOC entry 3438 (class 1259 OID 16640)
-- Name: auth_user_user_permissions_permission_id_1fbb5f2c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);


--
-- TOC entry 3441 (class 1259 OID 16639)
-- Name: auth_user_user_permissions_user_id_a95ead1b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);


--
-- TOC entry 3429 (class 1259 OID 16672)
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- TOC entry 3444 (class 1259 OID 16666)
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- TOC entry 3447 (class 1259 OID 16667)
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- TOC entry 3448 (class 1259 OID 16693)
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- TOC entry 3451 (class 1259 OID 16692)
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- TOC entry 3468 (class 2620 OID 16435)
-- Name: pacientes tg_paciente_para_triagem; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_paciente_para_triagem AFTER INSERT ON public.pacientes FOR EACH ROW EXECUTE FUNCTION public.inserir_na_triagem();


--
-- TOC entry 3469 (class 2620 OID 16422)
-- Name: pacientes trg_gerar_ticket; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_gerar_ticket BEFORE INSERT ON public.pacientes FOR EACH ROW EXECUTE FUNCTION public.atribuir_ticket();


--
-- TOC entry 3471 (class 2620 OID 24909)
-- Name: pacientes_triagem triagem_para_medico; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER triagem_para_medico AFTER INSERT OR UPDATE ON public.pacientes_triagem FOR EACH ROW EXECUTE FUNCTION public.move_para_medico();


--
-- TOC entry 3470 (class 2620 OID 16745)
-- Name: pacientes trigger_inserir_na_triagem; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_inserir_na_triagem AFTER INSERT ON public.pacientes FOR EACH ROW EXECUTE FUNCTION public.inserir_na_triagem();


--
-- TOC entry 3460 (class 2606 OID 16605)
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3461 (class 2606 OID 16600)
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3459 (class 2606 OID 16591)
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3462 (class 2606 OID 16620)
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3463 (class 2606 OID 16615)
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3464 (class 2606 OID 16634)
-- Name: auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3465 (class 2606 OID 16629)
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3466 (class 2606 OID 16656)
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3467 (class 2606 OID 16661)
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3458 (class 2606 OID 16494)
-- Name: triagem triagem_recepcao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triagem
    ADD CONSTRAINT triagem_recepcao_id_fkey FOREIGN KEY (recepcao_id) REFERENCES public.recepcao(id);


-- Completed on 2025-12-01 18:34:57 -03

--
-- PostgreSQL database dump complete
--

\unrestrict dVVwXAXuCwgeKxG3LLqBnrI2FPpiUp9d90mVIwb3ljHBdhuSffrCLyVKyjOvQM0

