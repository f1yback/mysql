select orderQuery.id           as ClientId,
       email,
       ordersCount,
       totalLeadsCount,
       round((totalLeadsCount / (dateDiff / 30))) as averageLeadsPerMonth,
       avgPrice,
       (totalLeadsCount * avgPrice) as totalMoney
from (select clients.id,
             email,
             count(o.id)         as ordersCount,
             totalLeadsCount,
             round(avg(o.price)) as avgPrice,
             datediff(dateEnd, dateStart) as dateDiff
      from clients
               left join orders o on o.client = clients.id
               left join (select count(lead_id) as totalLeadsCount, client_id, date
                          from leads_sent_report
                          where order_id in (select id from orders where orders.status = 'confirmed')
                          group by client_id) lsr
                         on lsr.client_id = o.client
               left join (select min(date) as dateStart, client_id from leads_sent_report group by client_id) dateStartQuery
                         on dateStartQuery.client_id = o.client
               left join (select max(date) as dateEnd, client_id from leads_sent_report group by client_id) dateEndQuery
                         on dateEndQuery.client_id = o.client
      where email is not null
        and o.status in ('confirmed')
      group by email
      order by ordersCount desc) orderQuery
