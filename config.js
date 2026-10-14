// Configuração do Supabase da VITABLOOM.
//
// Onde pegar: no painel do Supabase, abra o seu projeto e vá em
// Project Settings > API.
//   - SUPABASE_URL      -> campo "Project URL"
//   - SUPABASE_ANON_KEY -> campo "Project API keys", a chave "anon" "public"
//
// ATENÇÃO: use SOMENTE a chave "anon". NUNCA coloque a chave "service_role"
// aqui, porque este arquivo fica público no site.
// A chave anon é feita para ser pública; quem protege os dados são as
// regras (RLS) criadas pelo supabase-setup.sql.

var SUPABASE_URL = "https://mpvpftucizmxwxgocvqi.supabase.co";
var SUPABASE_ANON_KEY = "";
