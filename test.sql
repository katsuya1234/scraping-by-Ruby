Game analytics:  

mysql -h gii14.dev.gree.jp -u analytics -p 


SELECT
  date(uev_dt) as DATE, 
  gme_title as GAME,
  gme_version as VERSION,
  ptf_device as PLATFORM,
/* */
/* *** DO NOT EDIT BELOW THIS LINE *** */
/* */
  IFNULL(
    (
    SELECT 
      count(distinct child.uev_usr_id)
    FROM `gii_analytics`.`user_events` child
    WHERE child.uev_dt =master.uev_dt
    AND child.uev_gme_id=master.uev_gme_id
    /* AND child.uev_rgn_id=master.uev_rgn_id */
    AND child.uev_ptf_id=master.uev_ptf_id
    ), 0
  ) as DAU,



  IFNULL(
    (
    SELECT
      count(distinct child.uev_usr_id)
    FROM `gii_analytics`.`user_events` child
    WHERE child.uev_dt >= DATE_SUB(master.uev_dt, INTERVAL 30 DAY)
    AND child.uev_dt <= DATE_SUB(master.uev_dt, INTERVAL 0 DAY)
    AND child.uev_gme_id=master.uev_gme_id
    /* AND child.uev_rgn_id=master.uev_rgn_id */
    AND child.uev_ptf_id=master.uev_ptf_id
    ), 0
  ) as MAU_ROLL30,

  IFNULL(
    (
    SELECT 
      count(distinct uev_usr_id)
    FROM `gii_analytics`.`user_events` child
    WHERE child.uev_dt=master.uev_dt
      AND uev_usr_id NOT IN (
        SELECT subchild.uev_usr_id 
        FROM `gii_analytics`.`user_events` subchild
        WHERE subchild.uev_dt < child.uev_dt
        AND subchild.uev_gme_id=master.uev_gme_id
        /* AND subchild.uev_rgn_id=master.uev_rgn_id */
        AND subchild.uev_ptf_id=master.uev_ptf_id
      )
    AND child.uev_gme_id=master.uev_gme_id
    /* AND child.uev_rgn_id=master.uev_rgn_id */
    AND child.uev_ptf_id=master.uev_ptf_id
    ), 0
  ) as NEW_ACTIVATIONS,
  IFNULL(
    (
    SELECT
      count(distinct child.uev_usr_id)
    FROM `gii_analytics`.`user_events` child
    WHERE child.uev_dt <= master.uev_dt
    AND child.uev_gme_id=master.uev_gme_id
    /* AND child.uev_rgn_id=master.uev_rgn_id */
    AND child.uev_ptf_id=master.uev_ptf_id
    ), 0
  ) as TOTAL_USERS,
  IFNULL(
    (
    SELECT 
      count(distinct cse_usr_id)
    FROM `gii_analytics`.`currency_spend_events` child
    WHERE cse_cur_currency='_HC'
    AND child.cse_dt=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    ), 0
  ) as UU_SPENDERS,
  IFNULL(
    (
    SELECT 
      count(distinct cse_usr_id)
    FROM `gii_analytics`.`currency_spend_events` child
    WHERE child.cse_dt=master.uev_dt
      AND cse_usr_id NOT IN (
        SELECT subchild.cse_usr_id 
        FROM `gii_analytics`.`currency_spend_events` subchild
        WHERE subchild.cse_dt < child.cse_dt
        AND subchild.cse_cur_currency='_HC'
        AND subchild.cse_gme_id=master.uev_gme_id
        /* AND subchild.cse_rgn_id=master.uev_rgn_id */
        AND subchild.cse_ptf_id=master.uev_ptf_id
      )
    AND child.cse_cur_currency='_HC'
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    ), 0
  ) as NEW_UU_SPENDERS,
  IFNULL(
    (
    SELECT
      count(distinct cse_usr_id)
    FROM `gii_analytics`.`currency_spend_events` child
    WHERE cse_cur_currency='_HC'
    AND child.cse_dt<=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    ), 0
  ) as TOTAL_UU_SPENDERS,
  IFNULL(
    (
    SELECT 
      sum(cse_spend)
    FROM `gii_analytics`.`currency_spend_events` child
    WHERE cse_cur_currency='_HC'
    AND child.cse_dt=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    ), 0
  ) as HC_SPEND,
  IFNULL(
    (
    SELECT 
      sum(cse_spend)
    FROM `gii_analytics`.`currency_spend_events` child
    WHERE cse_cur_currency='_HC'
    AND child.cse_dt<=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    ), 0
  ) as TOTAL_HC_SPEND,
  IFNULL(
    (
    SELECT 
      sum(cge_gain) 
    FROM `gii_analytics`.`currency_gain_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cge_ctg_id
    WHERE cge_cur_currency='_HC'
    AND child.cge_dt=master.uev_dt
    AND child.cge_gme_id=master.uev_gme_id
    /* AND child.cge_rgn_id=master.uev_rgn_id */
    AND child.cge_ptf_id=master.uev_ptf_id
    AND child.cge_ctg_id <> 506/** PAID **/
    ), 0
  ) as HC_GAINED_EARNED,
  IFNULL(
    (
    SELECT 
      sum(cge_gain) 
    FROM `gii_analytics`.`currency_gain_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cge_ctg_id
    WHERE cge_cur_currency='_HC'
    AND child.cge_dt=master.uev_dt
    AND child.cge_gme_id=master.uev_gme_id
    /* AND child.cge_rgn_id=master.uev_rgn_id */
    AND child.cge_ptf_id=master.uev_ptf_id
    AND child.cge_ctg_id = 506/** Enter ID for PAID **/
    ), 0
  ) as HC_GAINED_PAID,
  IFNULL(
    (
    SELECT 
      sum(cge_gain) 
    FROM `gii_analytics`.`currency_gain_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cge_ctg_id
    WHERE cge_cur_currency='_HC'
    AND child.cge_dt<=master.uev_dt
    AND child.cge_gme_id=master.uev_gme_id
    /* AND child.cge_rgn_id=master.uev_rgn_id */
    AND child.cge_ptf_id=master.uev_ptf_id
    AND child.cge_ctg_id <> 506/** PAID **/
    ), 0
  ) as TOTAL_HC_GAINED_EARNED,
  IFNULL(
    (
    SELECT 
      sum(cge_gain) 
    FROM `gii_analytics`.`currency_gain_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cge_ctg_id
    WHERE cge_cur_currency='_HC'
    AND child.cge_dt<=master.uev_dt
    AND child.cge_gme_id=master.uev_gme_id
    /* AND child.cge_rgn_id=master.uev_rgn_id */
    AND child.cge_ptf_id=master.uev_ptf_id
    AND child.cge_ctg_id = 506/** Enter ID for PAID **/
    ), 0
  ) as TOTAL_HC_GAINED_PAID,
  IFNULL(
    (
    SELECT 
      count(sctg_name) as NUM_BOUGHT
    FROM `gii_analytics`.`currency_spend_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cse_ctg_id
      JOIN `gii_analytics`.`subcategories` subcat ON subcat.sctg_id = child.cse_subcategory_ctg_id
    WHERE cse_cur_currency='USD'
    AND child.cse_dt=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    AND child.cse_ctg_id = 516/** Enter ID for buying CURRENCY **/
    AND child.cse_subcategory_ctg_id = 416/** Enter ID for HC Package **/
    ), 0
  ) as HC10_BOUGHT,
  IFNULL(
    (
    SELECT 
      count(sctg_name) as NUM_BOUGHT
    FROM `gii_analytics`.`currency_spend_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cse_ctg_id
      JOIN `gii_analytics`.`subcategories` subcat ON subcat.sctg_id = child.cse_subcategory_ctg_id
    WHERE cse_cur_currency='USD'
    AND child.cse_dt=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    AND child.cse_ctg_id = 516/** Enter ID for buying CURRENCY **/
    AND child.cse_subcategory_ctg_id = 417/** Enter ID for HC Package **/
    ), 0
  ) as HC60_BOUGHT,
  IFNULL(
    (
    SELECT 
      count(sctg_name) as NUM_BOUGHT
    FROM `gii_analytics`.`currency_spend_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cse_ctg_id
      JOIN `gii_analytics`.`subcategories` subcat ON subcat.sctg_id = child.cse_subcategory_ctg_id
    WHERE cse_cur_currency='USD'
    AND child.cse_dt=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    AND child.cse_ctg_id = 516/** Enter ID for buying CURRENCY **/
    AND child.cse_subcategory_ctg_id = 418/** Enter ID for HC Package **/
    ), 0
  ) as HC125_BOUGHT,
  IFNULL(
    (
    SELECT 
      count(sctg_name) as NUM_BOUGHT
    FROM `gii_analytics`.`currency_spend_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cse_ctg_id
      JOIN `gii_analytics`.`subcategories` subcat ON subcat.sctg_id = child.cse_subcategory_ctg_id
    WHERE cse_cur_currency='USD'
    AND child.cse_dt=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    AND child.cse_ctg_id = 516/** Enter ID for buying CURRENCY **/
    AND child.cse_subcategory_ctg_id = 419/** Enter ID for HC Package **/
    ), 0
  ) as HC275_BOUGHT,
  IFNULL(
    (
    SELECT 
      count(sctg_name) as NUM_BOUGHT
    FROM `gii_analytics`.`currency_spend_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cse_ctg_id
      JOIN `gii_analytics`.`subcategories` subcat ON subcat.sctg_id = child.cse_subcategory_ctg_id
    WHERE cse_cur_currency='USD'
    AND child.cse_dt=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    AND child.cse_ctg_id = 516/** Enter ID for buying CURRENCY **/
    AND child.cse_subcategory_ctg_id = 420/** Enter ID for HC Package **/
    ), 0
  ) as HC700_BOUGHT,
  IFNULL(
    (
    SELECT 
      count(sctg_name) as NUM_BOUGHT
    FROM `gii_analytics`.`currency_spend_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cse_ctg_id
      JOIN `gii_analytics`.`subcategories` subcat ON subcat.sctg_id = child.cse_subcategory_ctg_id
    WHERE cse_cur_currency='USD'
    AND child.cse_dt=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    AND child.cse_ctg_id = 516/** Enter ID for buying CURRENCY **/
    AND child.cse_subcategory_ctg_id = 421/** Enter ID for HC Package **/
    ), 0
  ) as HC1500_BOUGHT,
  IFNULL(
    (
    SELECT 
      sum(cse_spend) as USD_SPENT
    FROM `gii_analytics`.`currency_spend_events` child
      JOIN `gii_analytics`.`categories` cat ON cat.ctg_id = child.cse_ctg_id
      JOIN `gii_analytics`.`subcategories` subcat ON subcat.sctg_id = child.cse_subcategory_ctg_id
    WHERE cse_cur_currency='USD'
    AND child.cse_dt=master.uev_dt
    AND child.cse_gme_id=master.uev_gme_id
    /* AND child.cse_rgn_id=master.uev_rgn_id */
    AND child.cse_ptf_id=master.uev_ptf_id
    AND child.cse_ctg_id = 516/** Enter ID for buying CURRENCY **/
    /** Can choose whether to specify individual HC Package **/
    ), 0
  ) as USD_EST_REV
/* */
/* *** DO NOT EDIT ABOVE THIS LINE *** */
/* */
FROM `gii_analytics`.`user_events` master
  JOIN `gii_analytics`.`games` g ON g.gme_id = master.uev_gme_id
  JOIN `gii_analytics`.`platforms` p ON p.ptf_id = master.uev_ptf_id
  /* JOIN `gii_analytics`.`regions` r ON r.rgn_id = master.uev_rgn_id */
WHERE
  uev_dt >= date_sub(curdate(), interval 30 day)
  AND gme_title = 'net.gree.dev.absorb'
  AND gme_version = '1.0'
  /* AND rgn_name LIKE '%' */
  AND ptf_device LIKE 'iOS'
GROUP BY
  DATE
ORDER BY
  DATE
;




