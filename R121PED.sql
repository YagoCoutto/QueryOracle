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
    trunc(e120ped.horfec / 60) || ':' || mod(e120ped.horfec, 60) AS hora_fech,
    e120ped.datprv       AS previsao,
    e120ped.pedblo       AS bloq,
    e120ped.datblo       AS data,
    trunc(e120ped.horblo / 60) || ':'|| mod(e120ped.horblo, 60) AS hora,   
    CASE
        WHEN e120ped.sitped = 1 || 4  AND e120ped.pedblo = 'S' THEN 'Imprimir'
        WHEN to_char(usu_tctrped.usu_datimp, 'DD/MM/YYYY') = '31/12/1900' THEN 'Pedido bloq.'
        ELSE
            to_char(usu_tctrped.usu_datimp, 'DD/MM/YYYY')
    END AS dat_imp,   
  
    trunc(usu_tctrped.usu_horimp / 60) || ':' || mod(usu_tctrped.usu_horimp, 60) AS hora_imprimido,
    e120ped.usu_libfat   AS liberado_fat,
    e140ipv.numnfv       AS nota_fiscal,
    e140ipv.codsnf       AS serie,
    CASE 
        WHEN E120PED.USU_LIBFAT = 'S' AND e120ped.sitped = 1 THEN 'Faturar'
        ELSE to_char(e140ipv.datger, 'DD/MM/YYYY') END AS Data,
    trunc (e140ipv.horger / 60) || ':' || mod(e140ipv.horger,60)       AS hora,
    e120ped.usuger       AS cod_usu,
    r999usu.nomusu       AS usuario,
    e073tra.nomtra       AS transportadora
FROM
    sapiens.e120ped left
    JOIN sapiens.e085cli ON sapiens.e120ped.codcli = sapiens.e085cli.codcli
    LEFT JOIN sapiens.e070emp ON sapiens.e120ped.codemp = sapiens.e070emp.codemp
    LEFT JOIN sapiens.usu_tctrped ON sapiens.e120ped.codemp = sapiens.usu_tctrped.usu_codemp
                                 AND sapiens.e120ped.codfil = sapiens.usu_tctrped.usu_codfil
                                 AND sapiens.e120ped.numped = sapiens.usu_tctrped.usu_numped
                                 AND sapiens.e120ped.datemi = sapiens.usu_tctrped.usu_datimp
                                 AND sapiens.usu_tctrped.usu_seqins = sapiens.usu_tctrped.usu_seqins
    LEFT JOIN sapiens.e140ipv ON sapiens.e120ped.codemp = sapiens.e140ipv.codemp
                                 AND sapiens.e120ped.codfil = sapiens.e140ipv.codfil
                                 AND sapiens.e140ipv.numped = sapiens.e120ped.numped

    LEFT JOIN sapiens.r999usu ON sapiens.e120ped.usuger = sapiens.r999usu.codusu
    LEFT JOIN sapiens.e073tra ON sapiens.e120ped.codtra = sapiens.e073tra.codtra
    LEFT JOIN sapiens.e085ent ON sapiens.e120ped.codcli = sapiens.e085ent.codcli
                                 AND sapiens.e120ped.seqent = sapiens.e085ent.seqent
WHERE
    e120ped.codemp = 25
    AND e120ped.codfil = 1
    AND e120ped.datblo >= to_date('26/09/2023','DD/MM/YYYY') and e120ped.datblo <= to_date('26/09/2023','DD/MM/YYYY')
    
GROUP BY
    e120ped.sitped,
    e120ped.numped,
    e120ped.datemi,
    e120ped.codcli,
    e085cli.apecli,
    e085cli.sigufs,
    e120ped.tnspro,
    e120ped.codfpg,
    e120ped.codemp,
    e120ped.codfil,
    e120ped.vlrori,
    e120ped.datprv,
    e120ped.pedblo,
    e120ped.datblo,
    e120ped.usu_libfat,
    e140ipv.numnfv,
    e140ipv.codsnf,
    e140ipv.datger,
    e140ipv.horger,
    e120ped.usuger,
    r999usu.nomusu,
    e073tra.nomtra,
    e085ent.estent,
    e085ent.cident,
    e085cli.cidcli,
    e120ped.horger,
    e120ped.horfec,
    e120ped.horblo,
    usu_tctrped.usu_datimp,
    usu_tctrped.usu_horimp,
    e120ped.vlrliq,
    sapiens.usu_tctrped.usu_seqins
ORDER BY
    e120ped.sitped,
    e120ped.numped,
    e085cli.apecli,
    e120ped.codemp,
    usu_tctrped.usu_seqins,
    sapiens.e140ipv.numnfv