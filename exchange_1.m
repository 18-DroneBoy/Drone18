Won = input("원화입력: ");
E = Won/1333;
E_500 = fix(E/500);
E__500 = mod(E,500);

E_200 = fix(E__500/200);
E__200 = mod(E__500,200);

E_100 = fix(E__200/100);
E__100 = mod(E__200,100);

E_50 = fix(E__100/50);
E__50 = mod(E__100,50);

E_20 = fix(E__50/20);
E__20 = mod(E__50,20);

E_10 = fix(E__20/10);
E__10 = mod(E__20,10);

E_5 = fix(E__10/5);

page_euro = E_500 + E_200 + E_100 + E_50 + E_20 + E_10 + E_5;

Dol = Won/1235;
D_100 = fix(Dol/100);
D__100 = mod(Dol,100);

D_50 = fix(D__100/50);
D__50 = mod(D__100, 50);

D_20 = fix(D__50/20);
D__20 = mod(D__50,20);

D_10 = fix(D__20/10);
D__10 = mod(D__20,10);

D_5 = fix(D__10/5);
D__5 = mod(D__10,5);

D_2 = fix(D__5/2);
D__2 = mod(D__5,2);

D_1 = fix(D__2/1);

page_dollor = D_100 + D_50 + D_20 + D_10 + D_5 + D_2 + D_1;

fprintf('유로 지폐의 개수 : %d, 달러 지폐의 개수 %d', page_euro, page_dollor)