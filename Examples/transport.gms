Set
   i 'canning plants' / seattle,  san-diego /
   j 'markets'        / new-york, chicago, topeka /;

Parameter
   a(i)    'capacity of plant i in cases'
           / seattle    350
             san-diego  600 /

   b(j)    'demand at market j in cases'
           / new-york   325
             chicago    300
             topeka     275 /
   esub(j) 'price elasticity of demand (at prices equal to unity)'
           / new-york   1.5
             chicago    1.2
             topeka     2.0 /;

Table d(i,j) 'distance in thousands of miles'
              new-york  chicago  topeka
   seattle         2.5      1.7     1.8
   san-diego       2.5      1.8     1.4;

Scalar f 'freight in dollars per case per thousand miles' / 90 /;

Parameter c(i,j) 'transport cost in thousands of dollars per case';
c(i,j) = f*d(i,j)/1000;

Parameter pbar(j) 'reference price at demand node j';

Positive Variable
   w(i)        'shadow price at supply node i'
   p(j)        'shadow price at demand node j'
   x(i,j)      'shipment quantities in cases';

Equation
   supply(i)   'supply limit at plant i'
   fxdemand(j) 'fixed demand at market j'
   prdemand(j) 'price-responsive demand at market j'
   profit(i,j) 'zero profit conditions';

profit(i,j)..  w(i) + c(i,j)  =g= p(j);

supply(i)..    a(i) =g= sum(j, x(i,j));

fxdemand(j)..  sum(i, x(i,j)) =g= b(j);

prdemand(j)..  sum(i, x(i,j)) =g= b(j)*(pbar(j)/p(j))**esub(j);

* declare models including specification of equation-variable association:
Model
   fixedqty / profit.x, supply.w, fxdemand.p /
   equilqty / profit.x, supply.w, prdemand.p /;

* initial estimate:
*p.l(j) = 1;
*w.l(i) = 1;

*x.l(i,j) = 1;

Parameter report(*,*,*) 'summary report';

solve fixedqty using mcp;