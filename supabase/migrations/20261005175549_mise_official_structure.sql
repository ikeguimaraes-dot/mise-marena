-- Estrutura complementar do MISE oficial. Nenhum registro de cliente.

BEGIN;

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA extensions;
CREATE FUNCTION public.op_unaccent(txt text) RETURNS text
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE SET search_path = pg_catalog, extensions
AS $$ SELECT extensions.unaccent('extensions.unaccent'::regdictionary, txt) $$;

CREATE TYPE "public"."op_86_motivo" AS ENUM (
    'compras',
    'producao',
    'fornecedor',
    'quebra',
    'outro',
    'compra_gestao',
    'producao_planejamento',
    'fornecedor_ruptura',
    'padrao_qualidade',
    'sazonalidade'
);

CREATE TYPE "public"."op_falta_area" AS ENUM (
    'salao',
    'cozinha_parrilla',
    'bar',
    'limpeza',
    'caixa'
);

CREATE TYPE "public"."op_feedback_categoria" AS ENUM (
    'prato',
    'servico',
    'pagamento',
    'ambiente',
    'outro'
);

CREATE TYPE "public"."op_feedback_tipo" AS ENUM (
    'reclamacao',
    'elogio'
);

CREATE TYPE "public"."op_periodo" AS ENUM (
    'manha',
    'almoco',
    'jantar',
    'eventos'
);

CREATE TYPE "public"."op_relatorio_status" AS ENUM (
    'rascunho',
    'enviado',
    'auditado',
    'divergente'
);

CREATE TYPE "public"."op_rh_ocorrencia_tipo" AS ENUM (
    'falta',
    'atestado',
    'saida_antecipada',
    'advertencia',
    'contratacao',
    'desligamento',
    'outro'
);

CREATE TABLE IF NOT EXISTS "mise"."checklist_template_topicos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "template_id" "uuid" NOT NULL,
    "topico_ordem" integer NOT NULL,
    "topico_nome" "text" NOT NULL,
    "peso" numeric DEFAULT 1 NOT NULL
);
CREATE TABLE IF NOT EXISTS "mise"."crivo_equipamentos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "local_id" "uuid" NOT NULL,
    "codigo" "text" NOT NULL,
    "nome" "text",
    "tipo" "text" NOT NULL,
    "area" "text",
    "ativo" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
CREATE TABLE IF NOT EXISTS "mise"."crivo_plano_acao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "execution_id" "uuid" NOT NULL,
    "response_id" "uuid",
    "descricao" "text" NOT NULL,
    "orientacao" "text",
    "responsavel_nome" "text",
    "responsavel_employee_id" "uuid",
    "prazo" "date",
    "status" "text" DEFAULT 'aberto'::"text" NOT NULL,
    "resolvido_em" timestamp with time zone,
    "resolvido_por" "uuid",
    "evidencia_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "crivo_plano_acao_status_check" CHECK (("status" = ANY (ARRAY['aberto'::"text", 'em_andamento'::"text", 'resolvido'::"text", 'cancelado'::"text"])))
);
CREATE TABLE IF NOT EXISTS "mise"."crivo_response_fotos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "response_id" "uuid" NOT NULL,
    "url" "text" NOT NULL,
    "legenda" "text",
    "ordem" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
CREATE TABLE IF NOT EXISTS "public"."op_86" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "relatorio_id" "uuid" NOT NULL,
    "periodo" "public"."op_periodo",
    "produto_nome" "text" NOT NULL,
    "produto_ref" "text",
    "motivo" "public"."op_86_motivo" NOT NULL,
    "observacao" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "setor" "text"
);
CREATE TABLE IF NOT EXISTS "public"."op_86_enxoval" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "relatorio_id" "uuid" NOT NULL,
    "periodo" "public"."op_periodo" NOT NULL,
    "item" "text" NOT NULL,
    "requerimento_feito" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
CREATE TABLE IF NOT EXISTS "public"."op_assinada" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "relatorio_id" "uuid" NOT NULL,
    "periodo" "public"."op_periodo",
    "categoria" "text" NOT NULL,
    "nome" "text" NOT NULL,
    "valor" numeric(14,2) NOT NULL,
    "observacao" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "numero_mesa" "text",
    "num_pessoas" integer
);
CREATE TABLE IF NOT EXISTS "public"."op_avaliacao_setor" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "relatorio_id" "uuid" NOT NULL,
    "periodo" "public"."op_periodo" NOT NULL,
    "setor" "text" NOT NULL,
    "nota" smallint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "observacao" "text",
    "sequencia" integer DEFAULT 1 NOT NULL,
    CONSTRAINT "op_avaliacao_setor_nota_check" CHECK ((("nota" >= 0) AND ("nota" <= 5)))
);
CREATE TABLE IF NOT EXISTS "public"."op_falta_equipe" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "relatorio_id" "uuid" NOT NULL,
    "periodo" "public"."op_periodo" NOT NULL,
    "area" "public"."op_falta_area" NOT NULL,
    "houve_falta" boolean DEFAULT false NOT NULL,
    "nomes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "lider_turno" "text",
    "sequencia" integer DEFAULT 1 NOT NULL
);
CREATE TABLE IF NOT EXISTS "public"."op_feedback_cliente" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "relatorio_id" "uuid" NOT NULL,
    "periodo" "public"."op_periodo",
    "tipo" "public"."op_feedback_tipo" NOT NULL,
    "categoria" "public"."op_feedback_categoria" NOT NULL,
    "produto_nome" "text",
    "texto" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "produto" "text"
);
CREATE TABLE IF NOT EXISTS "public"."op_horario_padrao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "unit_id" "uuid" NOT NULL,
    "dia_semana" integer NOT NULL,
    "periodo" "text" NOT NULL,
    "hora_abertura" time without time zone NOT NULL,
    "hora_fechamento" time without time zone NOT NULL
);
CREATE TABLE IF NOT EXISTS "public"."op_pendura" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "relatorio_id" "uuid" NOT NULL,
    "periodo" "public"."op_periodo",
    "comanda" "text",
    "cpf" "text",
    "nome" "text" NOT NULL,
    "valor" numeric(14,2) NOT NULL,
    "motivo" "text",
    "paga" boolean DEFAULT false NOT NULL,
    "paga_em" "date",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid"
);
CREATE TABLE IF NOT EXISTS "public"."op_portaria_desistencia" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "relatorio_id" "uuid" NOT NULL,
    "periodo" "public"."op_periodo",
    "pax_perdido" integer NOT NULL,
    "motivo" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "tipo" "text"
);
CREATE TABLE IF NOT EXISTS "public"."op_relatorio_diario" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "unit_id" "uuid" NOT NULL,
    "data" "date" NOT NULL,
    "status" "public"."op_relatorio_status" DEFAULT 'rascunho'::"public"."op_relatorio_status" NOT NULL,
    "resumo_dia" "text",
    "enviado_por" "uuid",
    "enviado_em" timestamp with time zone,
    "auditado_em" timestamp with time zone,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
CREATE TABLE IF NOT EXISTS "public"."op_relatorio_periodo" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "relatorio_id" "uuid" NOT NULL,
    "periodo" "public"."op_periodo" NOT NULL,
    "horario_abertura" time without time zone,
    "horario_ultimo_cliente" time without time zone,
    "horario_fechamento" time without time zone,
    "venda_total" numeric(14,2),
    "venda_alimentos" numeric(14,2),
    "venda_bebidas" numeric(14,2),
    "pax_total" integer,
    "pax_feminino" integer,
    "pax_masculino" integer,
    "taxa_servico" numeric(14,2),
    "delivery" numeric(14,2),
    "portaria" numeric(14,2),
    "saldo_consumacao" numeric(14,2),
    "evento_antecipado" numeric(14,2),
    "evento_na_operacao" numeric(14,2),
    "perda_produto" numeric(14,2),
    "clima_tempo" "text",
    "clima_temperatura" integer,
    "houve_ocorrencia" boolean DEFAULT false NOT NULL,
    "ocorrencia_texto" "text",
    "ticket_medio" numeric(14,2),
    "part_alimentos_pct" numeric(5,2),
    "part_bebidas_pct" numeric(5,2),
    "faturamento_periodo" numeric(14,2),
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "preenchido_por" "uuid",
    "portaria_reservas_previstas" integer,
    "portaria_noshow_qty" integer,
    "status" "text" DEFAULT 'rascunho'::"text" NOT NULL,
    "enviado_por" "uuid",
    "enviado_em" timestamp with time zone,
    "lider_turno" "text",
    "responsavel_preenchimento" "text",
    "perda_motivo" "text",
    "portaria_passantes" integer,
    "resumo_operacional" "text",
    "sequencia" integer DEFAULT 1 NOT NULL,
    "evento_nome" "text",
    "evento_contato" "text",
    "na_motivo" "text",
    "desconto" numeric,
    CONSTRAINT "op_relatorio_periodo_status_check" CHECK (("status" = ANY (ARRAY['rascunho'::"text", 'enviado'::"text", 'nao_se_aplica'::"text"])))
);
CREATE TABLE IF NOT EXISTS "public"."op_rh_ocorrencia" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "relatorio_id" "uuid" NOT NULL,
    "cpf" "text" NOT NULL,
    "nome" "text",
    "setor" "text",
    "tipo" "public"."op_rh_ocorrencia_tipo" NOT NULL,
    "observacao" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    CONSTRAINT "op_rh_ocorrencia_cpf_ck" CHECK (("cpf" ~ '^\d{11}$'::"text"))
);
CREATE TABLE IF NOT EXISTS "public"."op_unit_config" (
    "unit_id" "uuid" NOT NULL,
    "periodos" "public"."op_periodo"[] DEFAULT '{almoco,jantar}'::"public"."op_periodo"[] NOT NULL,
    "pax_por_genero" boolean DEFAULT false NOT NULL,
    "tolerancia_auditoria" numeric(5,2) DEFAULT 2.00 NOT NULL,
    "limite_extras_mes_cpf" integer DEFAULT 6 NOT NULL,
    "prazo_envio_horas" integer DEFAULT 2 NOT NULL,
    "escrita_habilitada" boolean DEFAULT false NOT NULL,
    "pdv_disponivel" boolean DEFAULT false NOT NULL,
    "cargos_checklist" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "mise"."checklist_execution_topicos" ADD COLUMN "zerado_por_critico" boolean DEFAULT false NOT NULL;

ALTER TABLE "mise"."checklist_execution_topicos" ADD COLUMN "peso" numeric;

ALTER TABLE "mise"."checklist_executions" ADD COLUMN "avaliador_nome" "text";

ALTER TABLE "mise"."checklist_executions" ADD COLUMN "avaliador_registro" "text";

ALTER TABLE "mise"."checklist_executions" ADD COLUMN "assinatura_avaliador_url" "text";

ALTER TABLE "mise"."checklist_executions" ADD COLUMN "responsavel_unidade_nome" "text";

ALTER TABLE "mise"."checklist_executions" ADD COLUMN "responsavel_unidade_cpf" "text";

ALTER TABLE "mise"."checklist_executions" ADD COLUMN "observacoes_gerais" "text";

ALTER TABLE "mise"."checklist_responses" ADD COLUMN "equipamento_id" "uuid";

ALTER TABLE "mise"."checklist_responses" ADD COLUMN "orientacao_corretiva" "text";

ALTER TABLE "mise"."checklist_responses" ADD COLUMN "responsavel_orientado" "text";

ALTER TABLE "mise"."checklist_template_items" ADD COLUMN "critico" boolean DEFAULT false NOT NULL;

ALTER TABLE "mise"."checklist_template_items" ADD COLUMN "por_equipamento" boolean DEFAULT false NOT NULL;

ALTER TABLE "mise"."checklist_template_items" ADD COLUMN "equipamento_tipo" "text";

ALTER TABLE "public"."employees" ADD COLUMN "is_system_account" boolean DEFAULT false NOT NULL;

ALTER TABLE "public"."employees" ADD COLUMN "nome_exibicao" "text";

ALTER TABLE "public"."units" ADD COLUMN "lorean_code" "text";

ALTER TABLE mise.checklist_executions ALTER COLUMN pontuacao_total TYPE numeric USING pontuacao_total::numeric;

ALTER TABLE mise.checklist_executions ALTER COLUMN pontuacao_obtida TYPE numeric USING pontuacao_obtida::numeric;

ALTER TABLE mise.checklist_template_items ALTER COLUMN peso TYPE numeric USING peso::numeric;

ALTER TABLE ONLY "mise"."checklist_template_topicos"
    ADD CONSTRAINT "checklist_template_topicos_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "mise"."checklist_template_topicos"
    ADD CONSTRAINT "checklist_template_topicos_template_id_topico_ordem_key" UNIQUE ("template_id", "topico_ordem");

ALTER TABLE ONLY "mise"."crivo_equipamentos"
    ADD CONSTRAINT "crivo_equipamentos_local_id_codigo_key" UNIQUE ("local_id", "codigo");

ALTER TABLE ONLY "mise"."crivo_equipamentos"
    ADD CONSTRAINT "crivo_equipamentos_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "mise"."crivo_plano_acao"
    ADD CONSTRAINT "crivo_plano_acao_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "mise"."crivo_response_fotos"
    ADD CONSTRAINT "crivo_response_fotos_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_86_enxoval"
    ADD CONSTRAINT "op_86_enxoval_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_86_enxoval"
    ADD CONSTRAINT "op_86_enxoval_relatorio_id_periodo_item_key" UNIQUE ("relatorio_id", "periodo", "item");

ALTER TABLE ONLY "public"."op_86"
    ADD CONSTRAINT "op_86_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_assinada"
    ADD CONSTRAINT "op_assinada_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_avaliacao_setor"
    ADD CONSTRAINT "op_avaliacao_setor_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_avaliacao_setor"
    ADD CONSTRAINT "op_avaliacao_setor_relatorio_id_periodo_sequencia_setor_key" UNIQUE ("relatorio_id", "periodo", "sequencia", "setor");

ALTER TABLE ONLY "public"."op_falta_equipe"
    ADD CONSTRAINT "op_falta_equipe_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_falta_equipe"
    ADD CONSTRAINT "op_falta_equipe_relatorio_id_periodo_sequencia_area_key" UNIQUE ("relatorio_id", "periodo", "sequencia", "area");

ALTER TABLE ONLY "public"."op_feedback_cliente"
    ADD CONSTRAINT "op_feedback_cliente_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_horario_padrao"
    ADD CONSTRAINT "op_horario_padrao_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_horario_padrao"
    ADD CONSTRAINT "op_horario_padrao_unit_id_dia_semana_periodo_key" UNIQUE ("unit_id", "dia_semana", "periodo");

ALTER TABLE ONLY "public"."op_pendura"
    ADD CONSTRAINT "op_pendura_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_portaria_desistencia"
    ADD CONSTRAINT "op_portaria_desistencia_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_relatorio_diario"
    ADD CONSTRAINT "op_relatorio_diario_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_relatorio_diario"
    ADD CONSTRAINT "op_relatorio_diario_unit_id_data_key" UNIQUE ("unit_id", "data");

ALTER TABLE ONLY "public"."op_relatorio_periodo"
    ADD CONSTRAINT "op_relatorio_periodo_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_relatorio_periodo"
    ADD CONSTRAINT "op_relatorio_periodo_relatorio_id_periodo_sequencia_key" UNIQUE ("relatorio_id", "periodo", "sequencia");

ALTER TABLE ONLY "public"."op_rh_ocorrencia"
    ADD CONSTRAINT "op_rh_ocorrencia_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."op_unit_config"
    ADD CONSTRAINT "op_unit_config_pkey" PRIMARY KEY ("unit_id");

ALTER TABLE ONLY "mise"."checklist_responses"
    ADD CONSTRAINT "checklist_responses_equipamento_id_fkey" FOREIGN KEY ("equipamento_id") REFERENCES "mise"."crivo_equipamentos"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "mise"."checklist_template_topicos"
    ADD CONSTRAINT "checklist_template_topicos_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "mise"."checklist_templates"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "mise"."crivo_equipamentos"
    ADD CONSTRAINT "crivo_equipamentos_local_id_fkey" FOREIGN KEY ("local_id") REFERENCES "mise"."crivo_locais"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "mise"."crivo_plano_acao"
    ADD CONSTRAINT "crivo_plano_acao_execution_id_fkey" FOREIGN KEY ("execution_id") REFERENCES "mise"."checklist_executions"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "mise"."crivo_plano_acao"
    ADD CONSTRAINT "crivo_plano_acao_response_id_fkey" FOREIGN KEY ("response_id") REFERENCES "mise"."checklist_responses"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "mise"."crivo_response_fotos"
    ADD CONSTRAINT "crivo_response_fotos_response_id_fkey" FOREIGN KEY ("response_id") REFERENCES "mise"."checklist_responses"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_86"
    ADD CONSTRAINT "op_86_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");

ALTER TABLE ONLY "public"."op_86_enxoval"
    ADD CONSTRAINT "op_86_enxoval_relatorio_id_fkey" FOREIGN KEY ("relatorio_id") REFERENCES "public"."op_relatorio_diario"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_86"
    ADD CONSTRAINT "op_86_relatorio_id_fkey" FOREIGN KEY ("relatorio_id") REFERENCES "public"."op_relatorio_diario"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_assinada"
    ADD CONSTRAINT "op_assinada_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");

ALTER TABLE ONLY "public"."op_assinada"
    ADD CONSTRAINT "op_assinada_relatorio_id_fkey" FOREIGN KEY ("relatorio_id") REFERENCES "public"."op_relatorio_diario"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_avaliacao_setor"
    ADD CONSTRAINT "op_avaliacao_setor_relatorio_id_fkey" FOREIGN KEY ("relatorio_id") REFERENCES "public"."op_relatorio_diario"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_falta_equipe"
    ADD CONSTRAINT "op_falta_equipe_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");

ALTER TABLE ONLY "public"."op_falta_equipe"
    ADD CONSTRAINT "op_falta_equipe_relatorio_id_fkey" FOREIGN KEY ("relatorio_id") REFERENCES "public"."op_relatorio_diario"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_feedback_cliente"
    ADD CONSTRAINT "op_feedback_cliente_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");

ALTER TABLE ONLY "public"."op_feedback_cliente"
    ADD CONSTRAINT "op_feedback_cliente_relatorio_id_fkey" FOREIGN KEY ("relatorio_id") REFERENCES "public"."op_relatorio_diario"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_horario_padrao"
    ADD CONSTRAINT "op_horario_padrao_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id");

ALTER TABLE ONLY "public"."op_pendura"
    ADD CONSTRAINT "op_pendura_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");

ALTER TABLE ONLY "public"."op_pendura"
    ADD CONSTRAINT "op_pendura_relatorio_id_fkey" FOREIGN KEY ("relatorio_id") REFERENCES "public"."op_relatorio_diario"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_portaria_desistencia"
    ADD CONSTRAINT "op_portaria_desistencia_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");

ALTER TABLE ONLY "public"."op_portaria_desistencia"
    ADD CONSTRAINT "op_portaria_desistencia_relatorio_id_fkey" FOREIGN KEY ("relatorio_id") REFERENCES "public"."op_relatorio_diario"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_relatorio_diario"
    ADD CONSTRAINT "op_relatorio_diario_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");

ALTER TABLE ONLY "public"."op_relatorio_diario"
    ADD CONSTRAINT "op_relatorio_diario_enviado_por_fkey" FOREIGN KEY ("enviado_por") REFERENCES "auth"."users"("id");

ALTER TABLE ONLY "public"."op_relatorio_diario"
    ADD CONSTRAINT "op_relatorio_diario_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_relatorio_periodo"
    ADD CONSTRAINT "op_relatorio_periodo_enviado_por_fkey" FOREIGN KEY ("enviado_por") REFERENCES "auth"."users"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."op_relatorio_periodo"
    ADD CONSTRAINT "op_relatorio_periodo_preenchido_por_fkey" FOREIGN KEY ("preenchido_por") REFERENCES "auth"."users"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."op_relatorio_periodo"
    ADD CONSTRAINT "op_relatorio_periodo_relatorio_id_fkey" FOREIGN KEY ("relatorio_id") REFERENCES "public"."op_relatorio_diario"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_rh_ocorrencia"
    ADD CONSTRAINT "op_rh_ocorrencia_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");

ALTER TABLE ONLY "public"."op_rh_ocorrencia"
    ADD CONSTRAINT "op_rh_ocorrencia_relatorio_id_fkey" FOREIGN KEY ("relatorio_id") REFERENCES "public"."op_relatorio_diario"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."op_unit_config"
    ADD CONSTRAINT "op_unit_config_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE CASCADE;

CREATE INDEX "idx_op_86_enxoval_rel" ON "public"."op_86_enxoval" USING "btree" ("relatorio_id");

CREATE INDEX "idx_op_86_produto" ON "public"."op_86" USING "btree" ("lower"("public"."op_unaccent"("produto_nome")));

CREATE INDEX "idx_op_86_rel" ON "public"."op_86" USING "btree" ("relatorio_id");

CREATE INDEX "idx_op_avaliacao_setor_rel" ON "public"."op_avaliacao_setor" USING "btree" ("relatorio_id");

CREATE INDEX "idx_op_falta_equipe_relatorio_id" ON "public"."op_falta_equipe" USING "btree" ("relatorio_id");

CREATE INDEX "idx_op_feedback_cat" ON "public"."op_feedback_cliente" USING "btree" ("categoria", "tipo");

CREATE INDEX "idx_op_feedback_rel" ON "public"."op_feedback_cliente" USING "btree" ("relatorio_id");

CREATE INDEX "idx_op_rel_periodo_rel" ON "public"."op_relatorio_periodo" USING "btree" ("relatorio_id");

CREATE INDEX "idx_op_relatorio_periodo_preenchido_por" ON "public"."op_relatorio_periodo" USING "btree" ("preenchido_por");

CREATE INDEX "idx_op_relatorio_status" ON "public"."op_relatorio_diario" USING "btree" ("status") WHERE ("status" <> 'auditado'::"public"."op_relatorio_status");

CREATE INDEX "idx_op_relatorio_unit_data" ON "public"."op_relatorio_diario" USING "btree" ("unit_id", "data" DESC);

CREATE INDEX "idx_op_rh_ocor_cpf" ON "public"."op_rh_ocorrencia" USING "btree" ("cpf");

CREATE OR REPLACE FUNCTION "public"."op_set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql" SET search_path = pg_catalog
    AS $$
begin
  new.updated_at = now();
  return new;
end $$;

CREATE OR REPLACE TRIGGER "op_86_enxoval_updated_at" BEFORE UPDATE ON "public"."op_86_enxoval" FOR EACH ROW EXECUTE FUNCTION "public"."op_set_updated_at"();

CREATE OR REPLACE TRIGGER "op_avaliacao_setor_updated_at" BEFORE UPDATE ON "public"."op_avaliacao_setor" FOR EACH ROW EXECUTE FUNCTION "public"."op_set_updated_at"();

CREATE OR REPLACE TRIGGER "op_falta_equipe_updated_at" BEFORE UPDATE ON "public"."op_falta_equipe" FOR EACH ROW EXECUTE FUNCTION "public"."op_set_updated_at"();

CREATE OR REPLACE TRIGGER "trg_op_relatorio_diario_updated" BEFORE UPDATE ON "public"."op_relatorio_diario" FOR EACH ROW EXECUTE FUNCTION "public"."op_set_updated_at"();

CREATE OR REPLACE TRIGGER "trg_op_relatorio_periodo_updated" BEFORE UPDATE ON "public"."op_relatorio_periodo" FOR EACH ROW EXECUTE FUNCTION "public"."op_set_updated_at"();

CREATE OR REPLACE TRIGGER "trg_op_unit_config_updated" BEFORE UPDATE ON "public"."op_unit_config" FOR EACH ROW EXECUTE FUNCTION "public"."op_set_updated_at"();

ALTER TABLE "mise"."checklist_template_topicos" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "mise"."checklist_template_topicos" FROM anon, authenticated;

GRANT ALL ON TABLE "mise"."checklist_template_topicos" TO service_role;

ALTER TABLE "mise"."crivo_equipamentos" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "mise"."crivo_equipamentos" FROM anon, authenticated;

GRANT ALL ON TABLE "mise"."crivo_equipamentos" TO service_role;

ALTER TABLE "mise"."crivo_plano_acao" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "mise"."crivo_plano_acao" FROM anon, authenticated;

GRANT ALL ON TABLE "mise"."crivo_plano_acao" TO service_role;

ALTER TABLE "mise"."crivo_response_fotos" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "mise"."crivo_response_fotos" FROM anon, authenticated;

GRANT ALL ON TABLE "mise"."crivo_response_fotos" TO service_role;

ALTER TABLE "public"."op_86" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_86" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_86" TO service_role;

ALTER TABLE "public"."op_86_enxoval" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_86_enxoval" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_86_enxoval" TO service_role;

ALTER TABLE "public"."op_assinada" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_assinada" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_assinada" TO service_role;

ALTER TABLE "public"."op_avaliacao_setor" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_avaliacao_setor" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_avaliacao_setor" TO service_role;

ALTER TABLE "public"."op_falta_equipe" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_falta_equipe" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_falta_equipe" TO service_role;

ALTER TABLE "public"."op_feedback_cliente" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_feedback_cliente" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_feedback_cliente" TO service_role;

ALTER TABLE "public"."op_horario_padrao" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_horario_padrao" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_horario_padrao" TO service_role;

ALTER TABLE "public"."op_pendura" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_pendura" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_pendura" TO service_role;

ALTER TABLE "public"."op_portaria_desistencia" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_portaria_desistencia" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_portaria_desistencia" TO service_role;

ALTER TABLE "public"."op_relatorio_diario" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_relatorio_diario" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_relatorio_diario" TO service_role;

ALTER TABLE "public"."op_relatorio_periodo" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_relatorio_periodo" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_relatorio_periodo" TO service_role;

ALTER TABLE "public"."op_rh_ocorrencia" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_rh_ocorrencia" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_rh_ocorrencia" TO service_role;

ALTER TABLE "public"."op_unit_config" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."op_unit_config" FROM anon, authenticated;

GRANT ALL ON TABLE "public"."op_unit_config" TO service_role;

COMMIT;
