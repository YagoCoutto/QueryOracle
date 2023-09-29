SELECT
    e120ped.sitped       AS situação_do_pedido,
    e120ped.numped       AS numero_do_pedido,
    e120ped.datemi       AS emissão,
    e120ped.codcli       AS cod_cliente,
    e085cli.apecli       AS cliente,
    e085cli.sigufs       AS uf,
    nvl(e085ent.estent, '-') AS dest,
    nvl(e085ent.cident, e085cli.cidcli) AS cidade,
    e120ped.tnspro       AS trans,
    e120ped.codfpg       AS forma_pgto,
    e120ped.codemp       AS empresa,
    e120ped.codfil       AS filial,
    CASE
        WHEN e120ped.vlrliq > 0 THEN
            e120ped.vlrliq
        ELSE
            e120ped.vlrori
    END AS vlrliq,
    e120ped.sitped       AS sit_pedido,
    e120ped.horger       AS h_dig,
    TRUNC(e120ped.horfec / 60)
    || ':'
    || MOD(e120ped.horfec, 60) AS hora_fech,
    e120ped.datprv       AS previsao,
    e120ped.pedblo       AS bloq,
    e120ped.datblo       AS DATA,
    TRUNC(e120ped.horblo / 60)
    || ':'
    || MOD(e120ped.horblo, 60) AS hora,
    CASE
        WHEN to_char(usu_tctrped.usu_datimp, 'DD/MM/YYYY') = '31/12/1900' AND E120PED.SITPED =1 AND E120PED.PEDBLO = 'N' THEN
            'imprimir'
        ELSE
            nvl(to_char(usu_tctrped.usu_datimp, 'DD/MM/YYYY'), ' ')
    END AS dat_imp,
    TRUNC(usu_tctrped.usu_horimp / 60)
    || ':'
    || MOD(usu_tctrped.usu_horimp, 60) AS hora_imprimido,
    e120ped.usu_libfat   AS liberado_fat,
    nvl(e140ipv.numnfv, e140isv.numnfv) AS nota_fiscal,
    nvl(e140ipv.codsnf, e140isv.codsnf) AS serie,
    CASE
        WHEN e120ped.usu_libfat = 'S'
             AND e120ped.sitped = 1 THEN
            'Faturar'
        ELSE
            nvl(to_char(e140ipv.datger, 'DD/MM/YYYY'), to_char(e140isv.datger, 'DD/MM/YYYY'))
    END AS DATA,
    nvl(TRUNC(e140ipv.horger / 60)
        || MOD(e140ipv.horger, 60), TRUNC(e140isv.horger / 60)
                                    || ':'
                                    || MOD(e140isv.horger, 60)) AS hora,
    e120ped.usuger       AS cod_usu,
    r999usu.nomusu       AS usuario,
    e073tra.nomtra       AS transportadora
FROM
    sapiens.e120ped LEFT
    JOIN sapiens.e085cli ON sapiens.e120ped.codcli = sapiens.e085cli.codcli
    LEFT JOIN sapiens.e070emp ON sapiens.e120ped.codemp = sapiens.e070emp.codemp
    LEFT JOIN sapiens.usu_tctrped ON sapiens.e120ped.codemp = sapiens.usu_tctrped.usu_codemp
                                     AND sapiens.e120ped.codfil = sapiens.usu_tctrped.usu_codfil
                                     AND sapiens.e120ped.numped = sapiens.usu_tctrped.usu_numped
                                     AND usu_tctrped.usu_seqins = (
                                     SELECT MIN(usu_seqins) 
                                     FROM usu_tctrped tctrped2 
                                     WHERE tctrped2.usu_codemp = usu_tctrped.usu_codemp AND tctrped2.usu_codfil = usu_tctrped.usu_codfil AND tctrped2.usu_numped = usu_tctrped.usu_numped)
    LEFT JOIN sapiens.e140ipv ON sapiens.e120ped.codemp = sapiens.e140ipv.codemp
                                 AND sapiens.e120ped.codfil = sapiens.e140ipv.codfil
                                 AND sapiens.e140ipv.numped = sapiens.e120ped.numped
                                 AND sapiens.e140ipv.seqipv = (
        SELECT
            MIN(seqipv)
        FROM
            sapiens.e140ipv e140ipv2
        WHERE
            sapiens.e140ipv2.codemp = e140ipv.codemp AND e140ipv2.codfil = e140ipv.codfil AND e140ipv2.numped = e140ipv.numped
    )
    LEFT JOIN sapiens.e140isv ON sapiens.e140isv.codemp = sapiens.e120ped.codemp
                                 AND sapiens.e140isv.codfil = sapiens.e120ped.codfil
                                 AND sapiens.e140isv.numped = sapiens.e120ped.numped
                                 AND sapiens.e140isv.seqisv = (
        SELECT
            MIN(seqisv)
        FROM
            sapiens.e140isv e140isv2
        WHERE
            e140isv2.codemp = e140isv.codemp AND e140isv2.codfil = e140isv2.codfil AND e140isv2.numped = e140isv.numped
    )
    LEFT JOIN sapiens.r999usu ON sapiens.e120ped.usuger = sapiens.r999usu.codusu
    LEFT JOIN sapiens.e073tra ON sapiens.e120ped.codtra = sapiens.e073tra.codtra
    LEFT JOIN sapiens.e085ent ON sapiens.e120ped.codcli = sapiens.e085ent.codcli
                                 AND sapiens.e120ped.seqent = sapiens.e085ent.seqent
WHERE
    e120ped.codemp BETWEEN 1 AND 29
    AND e120ped.codfil BETWEEN 1 AND 9
    AND e120ped.datblo BETWEEN TO_DATE('29/09/2023', 'DD/MM/YYYY') AND TO_DATE('29/09/2023', 'DD/MM/YYYY')
ORDER BY
    e120ped.sitped,
    e120ped.numped,
    e085cli.apecli