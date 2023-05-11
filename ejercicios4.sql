-- EJERCICIOS
/*

1 - Escriba un bloque de codigo PL/pgSQL que reciba una nota como parametro
    y notifique en la consola de mensaje las letras A,B,C,D,E o F segun el valor de la nota
*/
DO $$
declare num int = 5;
begin 
IF num >= 90 THEN
RAISE NOTICE 'La nota es: A';
ELSIF num >= 8 AND num < 9 THEN
RAISE NOTICE 'La nota es: B';
ELSIF num >= 7 AND num < 8 THEN
RAISE NOTICE 'La nota es: C';
ELSIF num >= 6 AND num < 7 THEN
RAISE NOTICE 'La nota es: D';
ELSIF num >= 5 AND num < 6 THEN
RAISE NOTICE 'La nota es: E';
ELSE
RAISE NOTICE 'La nota es: F';
END IF;
END $$ language 'plpgsql';


/*
2 - Escriba un bloque de codigo PL/pgSQL que reciba un numero como parametro
    y muestre la tabla de multiplicar de ese numero.
*/
DO $$
declare num int = 5;
declare i integer;
declare multiplicar integer;
begin 
FOR i IN 1..10 LOOP
		multiplicar:=num*i;
        RAISE NOTICE '%' ,multiplicar;		
    END LOOP;
END $$ language 'plpgsql';

/*
3 - Escriba una funcion PL/pgSQL que convierta de dolares a moneda nacional.
    La funcion debe recibir dos parametros, cantidad de dolares y tasa de cambio.
    Al final debe retornar el monto convertido a moneda nacional.
*/
CREATE OR REPLACE FUNCTION convertira(dollares NUMERIC, tasa numeric )
RETURNS NUMERIC AS $$
BEGIN
    RETURN dollares * tasa;
END;
$$ LANGUAGE plpgsql;

select convertira(5 , 0.91)

/*

4 - Escriba una funcion PL/pgSQL que reciba como parametro el monto de un prestamo,
    su duracion en meses y la tasa de interes, retornando el monto de la cuota a pagar.
    Aplicar el metodo de amortizacion frances.

*/
CREATE OR REPLACE FUNCTION cuota_prestamo(monto NUMERIC, duracion INTEGER, tasa NUMERIC)
RETURNS NUMERIC AS $$
DECLARE
    cuota NUMERIC;
    interes NUMERIC;
BEGIN
    interes := tasa / 100 / 12;
    cuota := monto * interes / (1 - (1 + interes) ^ (-duracion));
    RETURN cuota;
END $$ LANGUAGE 'plpgsql';
SELECT cuota_prestamo(100000, 12, 10);
/*
5 --función sin parametro de entrada para devolver el precio máximo
*/
CREATE OR REPLACE FUNCTION obtener_precio_maximo() RETURNS NUMERIC AS $$
DECLARE
    max_precio NUMERIC;
BEGIN
    SELECT MAX(unit_price) INTO max_precio FROM products;
    RETURN max_precio;
END $$ LANGUAGE plpgsql;


SELECT obtener_precio_maximo();

/*
6 --parametro de entrada
  --Obtener el numero de ordenes por empleado
*/
CREATE OR REPLACE FUNCTION obtener_ordenes(ide NUMERIC) RETURNS NUMERIC AS $$
DECLARE
    NUM_ORDENES NUMERIC;
BEGIN
    SELECT COUNT(order_id) INTO NUM_ORDENES FROM orders WHERE employee_id = ide;
    RETURN NUM_ORDENES;
END $$ LANGUAGE plpgsql;
JOIN order_details od ON o.order_id = od.order_id
SELECT obtener_ordenes(1);

/*
7--Obtener la venta de un empleado con un determinado producto
*/
CREATE OR REPLACE FUNCTION obtener_venta_empleado_producto(employe_id INTEGER, product INTEGER) RETURNS NUMERIC AS $$
DECLARE
    venta_total NUMERIC;
BEGIN
    SELECT SUM(quantity) INTO venta_total
    FROM order_details od
	JOIN Orders o ON od.order_id = o.order_id
	AND	o.employee_id =  employe_id
	AND	od.product_id = product;
    
    RETURN venta_total;
END $$ LANGUAGE plpgsql;
SELECT obtener_venta_empleado_producto(1, 2);
/*8-
Crear una funcion para devolver una tabla con producto_id, nombre, precio y unidades en strock, 
debe obtener los productos terminados en n
*/
CREATE OR REPLACE FUNCTION obtener_productos_terminados_en_n()
RETURNS TABLE (
    producto_id SMALLINT,
    nombre character varying,
    precio real,
    unidades_stock SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT product_id, product_name, unit_price, units_in_stock
    FROM products
    WHERE product_name ILIKE '%n';
END $$ LANGUAGE plpgsql;
SELECT * FROM obtener_productos_terminados_en_n();
/*9
-- Creamos la función contador_ordenes_anio()
--QUE CUENTE LAS ORDENES POR AÑO devuelve una tabla con año y contador
*/
CREATE OR REPLACE FUNCTION contador_ordenes_anio()
RETURNS TABLE (anio numeric, contador bigint) AS $$
BEGIN
    RETURN QUERY
    SELECT EXTRACT(YEAR FROM order_date)::numeric AS anio, COUNT(*) AS contador
    FROM orders
    GROUP BY anio
    ORDER BY anio;
END $$ LANGUAGE plpgsql;
SELECT * FROM contador_ordenes_anio();



/*10 Lo mismo que el ejemplo anterior pero con un parametro de entrada que sea el año
*/
CREATE OR REPLACE FUNCTION contador_ordenes_anio2(anno integer)
RETURNS TABLE (anio numeric, contador bigint) AS $$
BEGIN
    RETURN QUERY
    SELECT EXTRACT(YEAR FROM order_date)::numeric AS anio, COUNT(*) AS contador
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) = anno
    GROUP BY anio
    ORDER BY anio;
END $$ LANGUAGE plpgsql;

SELECT * FROM contador_ordenes_anio2(1996);
/*11 --PROCEDIMIENTO ALMACENADO PARA OBTENER PRECIO PROMEDIO Y SUMA DE 
--UNIDADES EN STOCK POR CATEGORIA
*/
CREATE OR REPLACE FUNCTION categoria_stock(categorid INTEGER)
RETURNS TABLE(avg_price double precision, sum_stock bigint)
AS $$
BEGIN
RETURN QUERY
SELECT avg(unit_price), sum(units_in_stock)
FROM products
WHERE category_id = categorid
GROUP BY category_id;
END;
$$
LANGUAGE plpgsql;
SELECT * FROM categoria_stock(1);