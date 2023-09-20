SELECT
  /*telemarketing*/
  e120ped.sitped AS SITUAÇÃO_DO_PEDIDO,
  e120ped.numped AS NUMERO_DO_PEDIDO,
  e120ped.datemi AS EMISSÃO,
  e120ped.codcli AS COD_CLIENTE,
  e085cli.apecli AS CLIENTE,
  e085cli.sigufs AS UF,
  NVL(E085Ent.EstEnt,'-') AS DEST,
  NVL(E085Ent.CidEnt,E085Cli.CidCli) AS CIDADE,
  e120ped.tnspro AS TRANS,
  e120ped.codfpg AS FORMA_PGTO,
  e120ped.codemp AS EMPRESA,
  e120ped.codfil AS FILIAL,
  e120ped.vlrori AS VLR_LIQ,
  E120PED.SitPed AS SIT_PEDIDO,
  e120ped.horger AS H_DIG,
  TRUNC(e120ped.horfec / 60) || ':' || MOD(e120ped.horfec, 60) AS HORA_FECH,
  e120ped.datprv AS PREVISAO,

  /*Financeiro*/
  e120ped.pedblo AS BLOQ,
  e120ped.datblo AS DATA,
  TRUNC(E120PED.HorBlo / 60) || ':' || MOD(E120PED.HorBlo, 60) AS HORA,

  /*Romaneio*/
   CASE
    WHEN E120PED.SITPED = 1 AND E120PED.PEDBLO= 'N' THEN 'Imprimir'
    WHEN TO_CHAR(usu_tctrped.usu_datimp, 'DD/MM/YYYY') = '31/12/1900' THEN 'Pedido bloq.'
    ELSE TO_CHAR(usu_tctrped.usu_datimp, 'DD/MM/YYYY') END AS DAT_IMP,
    
   CASE
    WHEN TRUNC(usu_tctrped.usu_horimp / 60) || ':' || MOD(usu_tctrped.usu_horimp, 60) = '0:0' THEN ''
    ELSE TRUNC(usu_tctrped.usu_horimp / 60) || ':' || MOD(usu_tctrped.usu_horimp, 60) END AS HORA_IMPRIMIDO,
    E120PED.USU_LIBFAT AS LIBERADO_FAT,   
    
  /*Faturamento*/
  e140ipv.numnfv AS NOTA_FISCAL,
  e140ipv.codsnf AS SERIE,
  e140ipv.datger AS DATA,
  e140ipv.horger AS HORA,
  
  /*usuario de geração do Pedido*/
  e120ped.usuger AS COD_USU,
  R999USU.NOMUSU AS USUARIO,
  
  /*Transportadora*/
  e073tra.NOMTRA AS TRANSPORTADORA

FROM
  E120PED
LEFT JOIN E085CLI ON E120PED.codcli = E085CLI.codcli
LEFT JOIN E070EMP ON E120PED.codemp = E070EMP.codemp
LEFT JOIN USU_TCTRPED ON E120PED.codemp = USU_TCTRPED.USU_codemp AND E120PED.CODFIL = USU_TCTRPED.USU_CODFIL AND E120PED.NUMPED = USU_TCTRPED.USU_NUMPED
LEFT JOIN E140IPV ON E120PED.CODEMP = E140IPV.CODEMP AND E120PED.CODFIL = E140IPV.CODFIL AND E140IPV.NUMPED = E120PED.NUMPED
LEFT JOIN R999USU ON E120PED.USUGER = R999USU.CODUSU
LEFT JOIN E073Tra ON E120PED.CODTRA = E073TRA.CODTRA
LEFT JOIN E085ENT ON E120PED.CODCLI = E085ENT.CODCLI AND E120PED.SEQENT = E085ENT.SEQENT
WHERE
  E120PED.CODEMP = 25 AND
  E120PED.CODFIL = 1 AND
  --E120PED.DATFEC = '20/09/2023' AND
  E120PED.DatBlo >= '15/09/2023' and E120PED.DatBlo <= '20/09/2023' AND
  --E120PED.DatPrv = ''
  --E120PED.DatEmi = ''

  1 = 1
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
  E120PED.USU_LIBFAT,
  e140ipv.numnfv,
  e140ipv.codsnf,
  e140ipv.datger,
  e140ipv.horger,
  e120ped.usuger,
  R999USU.NOMUSU,
  e073tra.NOMTRA,
  E085Ent.EstEnt,
  E085Ent.CidEnt,
  E085Cli.CidCli,
  e120ped.horger,
  e120ped.horfec,
  E120PED.HorBlo,
  usu_tctrped.usu_datimp,
  usu_tctrped.usu_horimp

ORDER BY 
      e120ped.sitped,
      e120ped.numped,
      e085cli.apecli

