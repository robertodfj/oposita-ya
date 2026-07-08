-- =====================================================================
--  OpositaYa · 003 · Contenido de prueba para Auxiliar Administrativo AGE
--  Ejecutar en Supabase → SQL Editor después de schema.sql.
--  Idempotente: si ya hay temario para esta oposición, no vuelve a insertar.
--  Preguntas originales basadas en textos legales (dominio público).
-- =====================================================================

do $$
declare
  v_opo uuid;
  v_b1 uuid; v_b2 uuid; v_b3 uuid; v_b4 uuid;
  v_t1 uuid; v_t2 uuid; v_t3 uuid; v_t4 uuid; v_t5 uuid; v_t6 uuid;
begin
  select id into v_opo from public.oposiciones where slug = 'auxiliar-age';
  if v_opo is null then
    raise notice 'No existe la oposición auxiliar-age. Ejecuta schema.sql primero.';
    return;
  end if;

  -- Si ya hay bloques para esta oposición, asumimos que ya está sembrado
  if exists (select 1 from public.bloques where oposicion_id = v_opo) then
    raise notice 'Ya hay contenido para auxiliar-age. No se inserta de nuevo.';
    return;
  end if;

  -- ---------- Bloques ----------
  insert into public.bloques(oposicion_id, nombre, orden) values (v_opo, 'Bloque I · Constitución', 1) returning id into v_b1;
  insert into public.bloques(oposicion_id, nombre, orden) values (v_opo, 'Bloque II · Ley 39/2015', 2) returning id into v_b2;
  insert into public.bloques(oposicion_id, nombre, orden) values (v_opo, 'Bloque III · Ley 40/2015', 3) returning id into v_b3;
  insert into public.bloques(oposicion_id, nombre, orden) values (v_opo, 'Bloque IV · Unión Europea', 4) returning id into v_b4;

  -- ---------- Temas ----------
  insert into public.temas(bloque_id, numero, titulo, ley_boe_id) values (v_b1, 1, 'La Constitución Española de 1978', 'BOE-A-1978-31229') returning id into v_t1;
  insert into public.temas(bloque_id, numero, titulo, ley_boe_id) values (v_b1, 2, 'Derechos y deberes fundamentales', 'BOE-A-1978-31229') returning id into v_t2;
  insert into public.temas(bloque_id, numero, titulo, ley_boe_id) values (v_b2, 3, 'El procedimiento administrativo común', 'BOE-A-2015-10565') returning id into v_t3;
  insert into public.temas(bloque_id, numero, titulo, ley_boe_id) values (v_b2, 4, 'Recursos administrativos y plazos', 'BOE-A-2015-10565') returning id into v_t4;
  insert into public.temas(bloque_id, numero, titulo, ley_boe_id) values (v_b3, 5, 'El sector público', 'BOE-A-2015-10566') returning id into v_t5;
  insert into public.temas(bloque_id, numero, titulo) values (v_b4, 6, 'Instituciones de la Unión Europea') returning id into v_t6;

  -- ---------- Preguntas ----------
  insert into public.preguntas(tema_id, oposicion_id, enunciado, opciones, indice_correcta, explicacion, fuente) values
  -- Tema 1: Constitución
  (v_t1, v_opo, '¿En qué fecha se aprobó en referéndum la Constitución Española?', '["6 de diciembre de 1978","27 de diciembre de 1978","29 de diciembre de 1978","1 de enero de 1979"]'::jsonb, 0, 'Fue ratificada en referéndum el 6 de diciembre de 1978.', 'oficial'),
  (v_t1, v_opo, 'Según el art. 1.1, España se constituye en un Estado…', '["social y democrático de Derecho","liberal y federal","democrático y republicano","autonómico y social"]'::jsonb, 0, 'Art. 1.1: Estado social y democrático de Derecho.', 'oficial'),
  (v_t1, v_opo, '¿Cuál es la forma política del Estado español (art. 1.3)?', '["República parlamentaria","Monarquía parlamentaria","Monarquía constitucional absoluta","Estado federal"]'::jsonb, 1, 'Art. 1.3: la forma política es la Monarquía parlamentaria.', 'oficial'),
  (v_t1, v_opo, 'La soberanía nacional reside en…', '["el Rey","las Cortes Generales","el pueblo español","el Gobierno"]'::jsonb, 2, 'Art. 1.2: la soberanía nacional reside en el pueblo español.', 'oficial'),
  (v_t1, v_opo, '¿Cuántos títulos tiene la Constitución (además del Preliminar)?', '["Diez","Nueve","Once","Ocho"]'::jsonb, 0, 'Tiene un Título Preliminar y diez títulos numerados.', 'oficial'),
  -- Tema 2: Derechos
  (v_t2, v_opo, 'Los derechos fundamentales y libertades públicas se recogen en la Sección 1ª del Capítulo II, artículos…', '["10 a 14","15 a 29","30 a 38","39 a 52"]'::jsonb, 1, 'Artículos 15 a 29 CE.', 'oficial'),
  (v_t2, v_opo, 'La mayoría de edad se establece en la Constitución a los…', '["16 años","18 años","21 años","20 años"]'::jsonb, 1, 'Art. 12: los españoles son mayores de edad a los 18 años.', 'oficial'),
  (v_t2, v_opo, 'El Defensor del Pueblo es un alto comisionado de…', '["el Gobierno","las Cortes Generales","el Rey","el Tribunal Constitucional"]'::jsonb, 1, 'Art. 54: alto comisionado de las Cortes Generales.', 'oficial'),
  (v_t2, v_opo, '¿Qué artículo reconoce el derecho a la tutela judicial efectiva?', '["Art. 24","Art. 14","Art. 18","Art. 27"]'::jsonb, 0, 'Art. 24 CE.', 'oficial'),
  (v_t2, v_opo, 'El derecho a la educación se recoge en el artículo…', '["25","26","27","28"]'::jsonb, 2, 'Art. 27 CE.', 'oficial'),
  -- Tema 3: Procedimiento
  (v_t3, v_opo, 'La Ley 39/2015 regula…', '["el régimen jurídico del sector público","el procedimiento administrativo común de las AAPP","el Gobierno","la transparencia"]'::jsonb, 1, 'La 39/2015 regula el Procedimiento Administrativo Común.', 'oficial'),
  (v_t3, v_opo, 'Salvo que una norma fije otro, el plazo máximo para resolver y notificar es de…', '["un mes","dos meses","tres meses","seis meses"]'::jsonb, 2, 'Art. 21.3: a falta de norma, tres meses.', 'oficial'),
  (v_t3, v_opo, 'Tienen la condición de interesados según el art. 4…', '["solo quienes promuevan el procedimiento","quienes lo promuevan o tengan derechos/intereses legítimos","únicamente las Administraciones","solo las personas jurídicas"]'::jsonb, 1, 'Art. 4: promotores y titulares de derechos o intereses legítimos.', 'oficial'),
  (v_t3, v_opo, 'El cómputo de plazos por días, cuando se señalan por días, se entienden…', '["naturales","hábiles, excluyendo sábados, domingos y festivos","solo laborables de lunes a viernes incluyendo festivos","siempre 30 días"]'::jsonb, 1, 'Art. 30: los plazos en días son hábiles (excluidos sábados, domingos y festivos).', 'oficial'),
  (v_t3, v_opo, 'La falta de resolución expresa en procedimientos iniciados a solicitud del interesado produce, con carácter general…', '["silencio negativo","silencio positivo salvo excepciones","caducidad automática","nulidad"]'::jsonb, 1, 'Art. 24: como regla general, silencio positivo, salvo excepciones.', 'oficial'),
  -- Tema 4: Recursos y plazos
  (v_t4, v_opo, 'El plazo para interponer un recurso de alzada, si el acto es expreso, es de…', '["quince días","un mes","dos meses","tres meses"]'::jsonb, 1, 'Art. 122: un mes si el acto es expreso.', 'oficial'),
  (v_t4, v_opo, 'El recurso potestativo de reposición se interpone ante…', '["el superior jerárquico","el mismo órgano que dictó el acto","el juez","el Defensor del Pueblo"]'::jsonb, 1, 'Art. 123-124: ante el mismo órgano que dictó el acto.', 'oficial'),
  (v_t4, v_opo, 'El plazo para interponer recurso de reposición contra acto expreso es de…', '["un mes","quince días","dos meses","diez días"]'::jsonb, 0, 'Art. 124: un mes si el acto es expreso.', 'oficial'),
  (v_t4, v_opo, 'El recurso extraordinario de revisión se interpone contra…', '["actos de trámite","actos firmes en vía administrativa","cualquier acto","disposiciones generales"]'::jsonb, 1, 'Art. 125: contra actos firmes en vía administrativa, por causas tasadas.', 'oficial'),
  -- Tema 5: Sector público
  (v_t5, v_opo, 'La Ley 40/2015 regula…', '["el procedimiento administrativo común","el régimen jurídico del sector público","el Gobierno","los presupuestos"]'::jsonb, 1, 'La 40/2015 regula el Régimen Jurídico del Sector Público.', 'oficial'),
  (v_t5, v_opo, 'No forma parte del sector público institucional estatal…', '["los organismos autónomos","las entidades públicas empresariales","las Cortes Generales","las agencias estatales"]'::jsonb, 2, 'Las Cortes Generales son un órgano constitucional, no sector público institucional.', 'oficial'),
  (v_t5, v_opo, 'Los órganos colegiados de las distintas administraciones se regulan en la…', '["Ley 39/2015","Ley 40/2015","Constitución","Ley 19/2013"]'::jsonb, 1, 'La 40/2015 regula los órganos colegiados.', 'oficial'),
  (v_t5, v_opo, 'Entre los principios de actuación del art. 3 de la Ley 40/2015 está…', '["la opacidad","el servicio efectivo a los ciudadanos","la jerarquía absoluta","la rigidez"]'::jsonb, 1, 'Art. 3: servicio efectivo a los ciudadanos, entre otros.', 'oficial'),
  -- Tema 6: UE
  (v_t6, v_opo, '¿Cuántas instituciones reconoce el art. 13 del TUE?', '["Cinco","Seis","Siete","Ocho"]'::jsonb, 2, 'El art. 13 TUE enumera siete instituciones.', 'oficial'),
  (v_t6, v_opo, 'La institución que representa a los ciudadanos de la UE y se elige por sufragio directo es…', '["el Consejo Europeo","el Parlamento Europeo","la Comisión","el Consejo de la UE"]'::jsonb, 1, 'El Parlamento Europeo se elige por sufragio universal directo.', 'oficial'),
  (v_t6, v_opo, 'La "guardiana de los Tratados" y con iniciativa legislativa es…', '["la Comisión Europea","el Parlamento","el Consejo","el TJUE"]'::jsonb, 0, 'La Comisión Europea vela por los Tratados y propone la legislación.', 'oficial'),
  (v_t6, v_opo, 'La sede oficial del Parlamento Europeo está en…', '["Bruselas","Luxemburgo","Estrasburgo","Fráncfort"]'::jsonb, 2, 'La sede oficial está en Estrasburgo.', 'oficial');

  -- ---------- Tests curados ----------
  insert into public.tests(oposicion_id, tema_id, titulo, descripcion, num_preguntas, es_simulacro) values
  (v_opo, v_t1, 'La Constitución de 1978', 'Test rápido del Título Preliminar y estructura.', 5, false),
  (v_opo, v_t2, 'Derechos y deberes fundamentales', 'Derechos fundamentales y libertades públicas.', 5, false),
  (v_opo, v_t3, 'Procedimiento administrativo (39/2015)', 'Conceptos clave del procedimiento común.', 5, false),
  (v_opo, v_t4, 'Recursos y plazos (39/2015)', 'Alzada, reposición y revisión.', 4, false),
  (v_opo, null, 'Simulacro general Auxiliar AGE', 'Preguntas de todos los bloques.', 20, true);

  raise notice 'Contenido de Auxiliar AGE insertado correctamente.';
end $$;
