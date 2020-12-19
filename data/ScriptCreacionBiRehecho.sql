use [GD2C2020]

/*Creacion del Schema*/
if(not exists(select * from sys.schemas where NAME = 'FSOCIETY'))
	begin
		exec('create schema[FSOCIETY]')
		print 'Creacion de Schema lista'
	end
go
/*Creacion de las dimensiones*/

--Tiempo
create table FSOCIETY.BI_Tiempo(
	tiempo_id int identity(1,1) primary key,
	anio int,
	mes int
)
go

	--Fill
	insert into FSOCIETY.BI_Tiempo
	select YEAR(compra_fecha), MONTH(compra_fecha) from FSOCIETY.Compra
		union
	select YEAR(factura_fecha), MONTH(factura_fecha) from FSOCIETY.Factura
	order by 1, 2
	go
	
--Funcion que asigna rango etario
create function FSOCIETY.BI_asignar_rango_etario (@edad int)
returns varchar(20)
begin
	
	return 
		case 
			when @edad between 18 and 30 then 'Entre 18 y 30 años'
			when @edad between 31 and 50 then 'Entre 31 y 50 años'
			else 'Mayor a 50 años'
		end

end
go

--Cliente
create table FSOCIETY.BI_cliente(
	cliente_id int primary key,
	cliente_nombre nvarchar(255),
	cliente_apellido nvarchar(255),
	cliente_direccion nvarchar(255),
	cliente_dni decimal(18,0),
	cliente_mail nvarchar(255),
	cliente_fecha_nac datetime2(3),
	cliente_sexo char(1),
	rango_etario varchar(20)
)
go

	--Fill
	insert into FSOCIETY.BI_cliente
	select c.cliente_id, c.cliente_nombre, c.cliente_apellido, c.cliente_direccion, c.cliente_dni, c.cliente_mail, c.cliente_fecha_nac, c.cliente_sexo, FSOCIETY.BI_asignar_rango_etario(DATEDIFF(yy, c.cliente_fecha_nac, GETDATE()))
	from FSOCIETY.Cliente c
	go

--Sucursal
create table FSOCIETY.BI_sucursal(
	sucursal_id int primary key,
	sucursal_direccion nvarchar(255),
	sucursal_mail nvarchar(255),
	sucursal_telefono decimal(18,0),
	sucursal_ciudad nvarchar(255)
)
go
	-- Fill
	insert into FSOCIETY.BI_sucursal
	select * from FSOCIETY.Sucursal
	go

--Fabricante autoparte
create table FSOCIETY.BI_fabricante_autoparte(
	fabricante_ap_codigo int primary key,
	fabricante_nombre nvarchar(255)
)
go

	--Fill
	insert into FSOCIETY.BI_fabricante_autoparte
	select distinct f.fabricante_codigo, f.fabricante_nombre from FSOCIETY.Auto_Parte ad join FSOCIETY.Fabricante f on ad.autoparte_fabricante_codigo = f.fabricante_codigo
	go

--Rubro Autoparte
create table FSOCIETY.BI_rubro_autoparte(
	rubro_codigo int identity(1,1) primary key,
	rubro_descripcion nvarchar(50)
)
go
	--Fill
	insert into FSOCIETY.BI_rubro_autoparte
	select distinct a.autoparte_rubro from FSOCIETY.Auto_Parte a
	go

--Factura
create table FSOCIETY.BI_factura(
	factura_nro_factura decimal(18,0) primary key,
	factura_sucursal int,
	factura_cliente_id int, --ESTO CAPAZ SE SACA
	factura_anio int,
	factura_mes int,
	factura_precio_facturado decimal(18,2),
	factura_cantidad_facturada decimal(18,0)
)
go
	--Constraints
	alter table FSOCIETY.BI_factura add constraint FK_BI_cliente_factura foreign key (factura_cliente_id) references FSOCIETY.BI_cliente(cliente_id)
	go

	--Fill
	insert into FSOCIETY.BI_factura
	select f.factura_nro_factura, f.factura_sucursal_id, f.factura_cliente_id, YEAR(f.factura_fecha), MONTH(f.factura_fecha), f.factura_precio_facturado, f.factura_cantidad_facturada
	from FSOCIETY.Factura f
	go

--Compra
create table FSOCIETY.BI_compra(
	compra_nro decimal(18,0) primary key,
	compra_sucursal int,
	compra_tipo_compra nchar(2),
	compra_precio_total decimal(18,2),
	compra_mes int,
	compra_anio int,
	compra_fecha datetime2(3)--Lo usamos para calcular el tiempo en stock de un modelo de automovil
)
go

	--Fill
	insert into FSOCIETY.BI_compra
	select c.compra_nro, c.compra_sucursal_id, c.compra_tipo_compra, c.compra_precio_total, MONTH(c.compra_fecha), YEAR(c.compra_fecha), c.compra_fecha 
	from FSOCIETY.Compra c
	go

--Autoparte
create table FSOCIETY.BI_autoparte(
	autoparte_codigo decimal(18,0) primary key,
	autoparte_descripcion nvarchar(255),
	autoparte_rubro int,
	autoparte_fabricante int
)
go
	--Constraint
	alter table FSOCIETY.BI_autoparte add constraint FK_BI_autoparte_fabricante foreign key (autoparte_fabricante) references FSOCIETY.BI_fabricante_autoparte(fabricante_ap_codigo)
	alter table FSOCIETY.BI_autoparte add constraint FK_BI_autoparte_rubro foreign key (autoparte_rubro) references FSOCIETY.BI_rubro_autoparte(rubro_codigo)
	go

	--Fill
	insert into FSOCIETY.BI_autoparte
	select a.autoparte_codigo, a.autoparte_descripcion, 1, a.autoparte_fabricante_codigo from FSOCIETY.Auto_Parte a
	go

/* CREACION DE TABLAS DE HECHOS */

	-- VENTA DE AUTOPARTES
	create table FSOCIETY.BI_Venta_Autopartes(
		tiempo_id int,
		cliente int,
		factura decimal(18,0),
		sucursal int,
		autoparte decimal(18,0),
		fabricante int,
		rubro_autoparte int,
		cantidad_vendida int,
		precio_unitario decimal(18,2)
	)
	go
		--Constraint
		alter table FSOCIETY.BI_Venta_Autopartes add constraint FK_BI_VAP_tiempo foreign key (tiempo_id) references FSOCIETY.BI_tiempo(tiempo_id)	
		alter table FSOCIETY.BI_Venta_Autopartes add constraint FK_BI_VAP_cliente foreign key (cliente) references FSOCIETY.BI_cliente(cliente_id)
		alter table FSOCIETY.BI_Venta_Autopartes add constraint FK_BI_VAP_factura foreign key (factura) references FSOCIETY.BI_Factura(factura_nro_factura)
		alter table FSOCIETY.BI_Venta_Autopartes add constraint FK_BI_VAP_sucursal foreign key (sucursal) references FSOCIETY.BI_sucursal(sucursal_id)
		alter table FSOCIETY.BI_Venta_Autopartes add constraint FK_BI_VAP_fabricante foreign key (fabricante) references FSOCIETY.BI_fabricante_autoparte(fabricante_ap_codigo)
		alter table FSOCIETY.BI_Venta_Autopartes add constraint FK_BI_VAP_rubro_autoparte foreign key (rubro_autoparte) references FSOCIETY.BI_rubro_autoparte(rubro_codigo)
		alter table FSOCIETY.BI_Venta_Autopartes add constraint FK_BI_VAP_autoparte foreign key (autoparte) references FSOCIETY.BI_autoparte(autoparte_codigo)
		go

		--Fill
		insert into FSOCIETY.BI_Venta_Autopartes
		select t.tiempo_id, c.cliente_id, f.factura_nro_factura, s.sucursal_id, ap.autoparte_codigo, fap.fabricante_ap_codigo, rap.rubro_codigo, va.venta_autoparte_cantidad, va.venta_autoparte_precio_unitario
		from FSOCIETY.BI_factura f
			join FSOCIETY.BI_Tiempo t on f.factura_anio = t.anio and f.factura_mes = t.mes
			join FSOCIETY.BI_cliente c on f.factura_cliente_id = c.cliente_id
			join FSOCIETY.BI_sucursal s on f.factura_sucursal = s.sucursal_id
			join FSOCIETY.Venta_Autoparte va on f.factura_nro_factura = va.venta_autoparte_factura_nro
			join FSOCIETY.BI_autoparte ap on va.venta_autoparte_autoparte_id = ap.autoparte_codigo
			join FSOCIETY.BI_fabricante_autoparte fap on ap.autoparte_fabricante = fap.fabricante_ap_codigo
			join FSOCIETY.BI_rubro_autoparte rap on rap.rubro_codigo = ap.autoparte_rubro 
		go

	-- COMPRA DE AUTOPARTES
	create table FSOCIETY.BI_Compra_Autopartes(
		tiempo_id int,
		compra decimal(18,0),
		sucursal int,
		autoparte decimal(18,0),
		fabricante int,
		rubro_autoparte int,
		cantidad_comprada int,
		precio_unitario decimal(18,2)
	)
	go

	-- Constraints
		alter table FSOCIETY.BI_Compra_Autopartes add constraint FK_BI_CAP_tiempo foreign key (tiempo_id) references FSOCIETY.BI_Tiempo(tiempo_id)
		alter table FSOCIETY.BI_Compra_Autopartes add constraint FK_BI_CAP_compra foreign key (compra) references FSOCIETY.BI_compra(compra_nro)
		alter table FSOCIETY.BI_Compra_Autopartes add constraint FK_BI_CAP_sucursal foreign key (sucursal) references FSOCIETY.BI_sucursal(sucursal_id)
		alter table FSOCIETY.BI_Compra_Autopartes add constraint FK_BI_CAP_fabricante foreign key (fabricante) references FSOCIETY.BI_fabricante_autoparte(fabricante_ap_codigo)
		alter table FSOCIETY.BI_Compra_Autopartes add constraint FK_BI_CAP_rubro foreign key (rubro_autoparte) references FSOCIETY.BI_rubro_autoparte(rubro_codigo)
		alter table FSOCIETY.BI_Compra_Autopartes add constraint FK_BI_CAP_autoparte foreign key (autoparte) references FSOCIETY.BI_autoparte(autoparte_codigo)
		go
	
	--Fill
		insert into FSOCIETY.BI_Compra_Autopartes
		select t.tiempo_id, co.compra_nro, s.sucursal_id, ap.autoparte_codigo, fap.fabricante_ap_codigo, rap.rubro_codigo, ca.compra_autoparte_cantidad, ca.compra_autoparte_precio_unitario
		from FSOCIETY.BI_compra co
			join FSOCIETY.BI_Tiempo t on co.compra_anio = t.anio and co.compra_mes = t.mes
			join FSOCIETY.BI_sucursal s on co.compra_sucursal = s.sucursal_id
			join FSOCIETY.Compra_Autoparte ca on co.compra_nro = ca.compra_autoparte_compra_id
			join FSOCIETY.BI_autoparte ap on ca.compra_autoparte_autoparte_id = ap.autoparte_codigo
			join FSOCIETY.BI_fabricante_autoparte fap on ap.autoparte_fabricante = fap.fabricante_ap_codigo
			join FSOCIETY.BI_rubro_autoparte rap on rap.rubro_codigo = ap.autoparte_rubro 
		go

/* CREACION DE VISTAS */

	-- Ganancias x sucursal x mes
	create view FSOCIETY.BI_ganancias_sucursal_mes_autoparte as 
		select s.sucursal_id, t.mes, sum(va.precio_unitario * va.cantidad_vendida - ca.precio_unitario * ca.cantidad_comprada) as ganancia from FSOCIETY.BI_compra c
			join FSOCIETY.BI_Compra_Autopartes ca on c.compra_nro = ca.compra
			join FSOCIETY.BI_Venta_Autopartes va on va.autoparte = ca.autoparte
			join FSOCIETY.BI_factura f on f.factura_nro_factura = va.factura
			join FSOCIETY.BI_sucursal s on s.sucursal_id = f.factura_sucursal
			join FSOCIETY.BI_Tiempo t on va.tiempo_id = t.tiempo_id
		group by s.sucursal_id, t.mes
	go

	-- Precio Promedio de Autoparte vendida y comprada
	create view FSOCIETY.BI_precio_promedio_AP_vendida_comprada as
		select a.autoparte_codigo, cast(AVG(ca.precio_unitario) as decimal(18,2)) as precio_promedio_compra, cast(AVG(va.precio_unitario) as decimal(18,2)) as precio_promedio_venta from FSOCIETY.BI_autoparte a
			join FSOCIETY.BI_Compra_Autopartes ca on ca.autoparte = a.autoparte_codigo
			join FSOCIETY.BI_Venta_Autopartes va on va.autoparte = a.autoparte_codigo
		group by a.autoparte_codigo
	go
	
/*
	Templates
	alter table FSOCIETY.BI_ add constraint FK_BI_AP_ foreign key () references FSOCIETY.BI_()
*/
/*
	DROPS

drop table FSOCIETY.BI_Venta_Autopartes
drop table FSOCIETY.BI_Compra_Autopartes
drop table FSOCIETY.BI_autoparte
drop table FSOCIETY.BI_factura
drop table FSOCIETY.BI_compra
drop table FSOCIETY.BI_cliente
drop table FSOCIETY.BI_rubro_autoparte
drop table FSOCIETY.BI_fabricante_autoparte
drop table FSOCIETY.BI_sucursal
drop table FSOCIETY.BI_tiempo

drop function FSOCIETY.BI_asignar_rango_etario
*/