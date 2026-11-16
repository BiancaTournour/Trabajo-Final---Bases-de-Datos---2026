SELECT tgname
FROM pg_trigger
WHERE tgname = 'tgr_horario_servicio_sin_superposicion'
AND NOT tgisinternal;

--es para ver si se crean o no los triggers :)