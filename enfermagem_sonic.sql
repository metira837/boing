--
-- PostgreSQL database dump
--

\restrict g32HlcSmi1WFsjBx4vF8gNtpraH0QAYteuLu1ZCgGDHFGTeYaiJuBS4TCpS3Am9

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

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

        IF NOT EXISTS (SELECT 1 FROM pacientes WHERE ticket = novo_ticket) THEN
            RETURN novo_ticket;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION public.gerar_ticket() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_user (
    id integer CONSTRAINT admin_id_not_null NOT NULL,
    nome character varying(20) CONSTRAINT admin_nome_not_null NOT NULL,
    "função" character varying(10) CONSTRAINT "admin_função_not_null" NOT NULL,
    senha character varying(50) CONSTRAINT admin_senha_not_null NOT NULL,
    usuario character varying(50)
);


ALTER TABLE public.admin_user OWNER TO postgres;

--
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
-- Name: admin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_id_seq OWNED BY public.admin_user.id;


--
-- Name: pacientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pacientes (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    idade integer NOT NULL,
    sexo character varying(10) NOT NULL,
    ticket character varying(5) NOT NULL,
    documentos character varying(20),
    contato smallint,
    data timestamp without time zone
);


ALTER TABLE public.pacientes OWNER TO postgres;

--
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
-- Name: pacientes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pacientes_id_seq OWNED BY public.pacientes.id;


--
-- Name: pacientes_triagem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pacientes_triagem (
    id integer,
    nome character varying(100),
    idade integer,
    sexo character varying(10),
    ticket character(3),
    alergias character varying(20),
    pressao real,
    altura real,
    perigo smallint NOT NULL,
    temperatura real,
    queixa character varying(50),
    data timestamp without time zone,
    peso real,
    documentos character varying(20),
    contato smallint
);


ALTER TABLE public.pacientes_triagem OWNER TO postgres;

--
-- Name: admin_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_user ALTER COLUMN id SET DEFAULT nextval('public.admin_id_seq'::regclass);


--
-- Name: pacientes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes ALTER COLUMN id SET DEFAULT nextval('public.pacientes_id_seq'::regclass);


--
-- Data for Name: admin_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_user (id, nome, "função", senha, usuario) FROM stdin;
1	tux	tecnico	cu12	tux
4	sonic	médico	cu123	sonic
\.


--
-- Data for Name: pacientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pacientes (id, nome, idade, sexo, ticket, documentos, contato, data) FROM stdin;
4	sonic	10	masculino	G95	\N	\N	\N
6	tux	12	masculino	R84	saudsa	123	\N
\.


--
-- Data for Name: pacientes_triagem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pacientes_triagem (id, nome, idade, sexo, ticket, alergias, pressao, altura, perigo, temperatura, queixa, data, peso, documentos, contato) FROM stdin;
\.


--
-- Name: admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_id_seq', 4, true);


--
-- Name: pacientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pacientes_id_seq', 6, true);


--
-- Name: admin_user admin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_user
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id);


--
-- Name: pacientes pacientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes
    ADD CONSTRAINT pacientes_pkey PRIMARY KEY (id);


--
-- Name: pacientes trg_gerar_ticket; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_gerar_ticket BEFORE INSERT ON public.pacientes FOR EACH ROW EXECUTE FUNCTION public.atribuir_ticket();


--
-- PostgreSQL database dump complete
--

\unrestrict g32HlcSmi1WFsjBx4vF8gNtpraH0QAYteuLu1ZCgGDHFGTeYaiJuBS4TCpS3Am9

