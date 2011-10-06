--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attendees; Type: TABLE; Schema: public; Owner: ticketerator; Tablespace: 
--

CREATE TABLE attendees (
    attendee_id integer NOT NULL,
    attendee_givenname text,
    attendee_surname text,
    attendee_email text NOT NULL
);


ALTER TABLE public.attendees OWNER TO ticketerator;

--
-- Name: attendees_attendee_id_seq; Type: SEQUENCE; Schema: public; Owner: ticketerator
--

CREATE SEQUENCE attendees_attendee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attendees_attendee_id_seq OWNER TO ticketerator;

--
-- Name: attendees_attendee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ticketerator
--

ALTER SEQUENCE attendees_attendee_id_seq OWNED BY attendees.attendee_id;


--
-- Name: attendees_attendee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ticketerator
--

SELECT pg_catalog.setval('attendees_attendee_id_seq', 46, true);


--
-- Name: events; Type: TABLE; Schema: public; Owner: ticketerator; Tablespace: 
--

CREATE TABLE events (
    event_id integer NOT NULL,
    event_name text NOT NULL,
    event_speaker text,
    event_location text NOT NULL,
    event_instructions text,
    event_starttime time with time zone,
    event_date date
);


ALTER TABLE public.events OWNER TO ticketerator;

--
-- Name: events_event_id_seq; Type: SEQUENCE; Schema: public; Owner: ticketerator
--

CREATE SEQUENCE events_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_event_id_seq OWNER TO ticketerator;

--
-- Name: events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ticketerator
--

ALTER SEQUENCE events_event_id_seq OWNED BY events.event_id;


--
-- Name: events_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ticketerator
--

SELECT pg_catalog.setval('events_event_id_seq', 1, true);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: ticketerator; Tablespace: 
--

CREATE TABLE settings (
    settings_salt text
);


ALTER TABLE public.settings OWNER TO ticketerator;

--
-- Name: ticket_level; Type: TABLE; Schema: public; Owner: ticketerator; Tablespace: 
--

CREATE TABLE ticket_level (
    ticket_level_id integer NOT NULL,
    ticket_level_name text NOT NULL,
    ticket_level_cost double precision NOT NULL
);


ALTER TABLE public.ticket_level OWNER TO ticketerator;

--
-- Name: ticket_level_ticket_level_id_seq; Type: SEQUENCE; Schema: public; Owner: ticketerator
--

CREATE SEQUENCE ticket_level_ticket_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ticket_level_ticket_level_id_seq OWNER TO ticketerator;

--
-- Name: ticket_level_ticket_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ticketerator
--

ALTER SEQUENCE ticket_level_ticket_level_id_seq OWNED BY ticket_level.ticket_level_id;


--
-- Name: ticket_level_ticket_level_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ticketerator
--

SELECT pg_catalog.setval('ticket_level_ticket_level_id_seq', 4, false);


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: ticketerator; Tablespace: 
--

CREATE TABLE tickets (
    ticket_id integer NOT NULL,
    ticket_event_id_fk integer,
    ticket_attendee_id_fk integer,
    ticket_level_id_fk integer,
    ticket_paid boolean,
    ticket_sent boolean
);


ALTER TABLE public.tickets OWNER TO ticketerator;

--
-- Name: tickets_ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: ticketerator
--

CREATE SEQUENCE tickets_ticket_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_ticket_id_seq OWNER TO ticketerator;

--
-- Name: tickets_ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ticketerator
--

ALTER SEQUENCE tickets_ticket_id_seq OWNED BY tickets.ticket_id;


--
-- Name: tickets_ticket_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ticketerator
--

SELECT pg_catalog.setval('tickets_ticket_id_seq', 45, true);


--
-- Name: attendee_id; Type: DEFAULT; Schema: public; Owner: ticketerator
--

ALTER TABLE attendees ALTER COLUMN attendee_id SET DEFAULT nextval('attendees_attendee_id_seq'::regclass);


--
-- Name: event_id; Type: DEFAULT; Schema: public; Owner: ticketerator
--

ALTER TABLE events ALTER COLUMN event_id SET DEFAULT nextval('events_event_id_seq'::regclass);


--
-- Name: ticket_level_id; Type: DEFAULT; Schema: public; Owner: ticketerator
--

ALTER TABLE ticket_level ALTER COLUMN ticket_level_id SET DEFAULT nextval('ticket_level_ticket_level_id_seq'::regclass);


--
-- Name: ticket_id; Type: DEFAULT; Schema: public; Owner: ticketerator
--

ALTER TABLE tickets ALTER COLUMN ticket_id SET DEFAULT nextval('tickets_ticket_id_seq'::regclass);


--
-- Name: attendees_pkey; Type: CONSTRAINT; Schema: public; Owner: ticketerator; Tablespace: 
--

ALTER TABLE ONLY attendees
    ADD CONSTRAINT attendees_pkey PRIMARY KEY (attendee_id);


--
-- Name: ticket_level_pkey; Type: CONSTRAINT; Schema: public; Owner: ticketerator; Tablespace: 
--

ALTER TABLE ONLY ticket_level
    ADD CONSTRAINT ticket_level_pkey PRIMARY KEY (ticket_level_id);


--
-- Name: tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: ticketerator; Tablespace: 
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (ticket_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: ticketerator
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM ticketerator;
GRANT ALL ON SCHEMA public TO ticketerator;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--
