use [GD2C2020]

/*Creacion del Schema*/
if(not exists(select * from sys.schemas where NAME = 'FSOCIETY'))
	begin
		exec('create schema[FSOCIETY]')
		print 'Creacion de Schema lista'
	end
go
/*Creacion de las dimensiones*/

/*
--Tiempo1
create table FSOCIETY.BI_Tiempo(
	fecha datetime2(3) primary key,
	anio int,
	mes int
)
go
	--Fill 1
	insert into FSOCIETY.BI_Tiempo
		select compra_fecha, YEAR(compra_fecha), MONTH(compra_fecha) from FSOCIETY.Compra
		group by compra_fecha
		union
		select factura_fecha, YEAR(factura_fecha), MONTH(factura_fecha) from FSOCIETY.Factura
		group by factura_fecha
	order by 1, 2, 3
	go
*/

--Tiempo 2
create table FSOCIETY.BI_Tiempo(
	tiempo_id int identity(1,1) primary key,
	anio int,
	mes int
)
go

	--Fill 2
	insert into FSOCIETY.BI_Tiempo
	select YEAR(compra_fecha), MONTH(compra_fecha) from FSOCIETY.Compra
		union
	select YEAR(factura_fecha), MONTH(factura_fecha) from FSOCIETY.Factura
	order by 1, 2
	go

--Rango etario
create table FSOCIETY.BI_rango_etario(
	rango_etario_id int identity(1,1) primary key,
	rango_etario_descripcion nvarchar(30),
	edad_inferior int,
	edad_superior int null
)
go 
	--Fill
	insert into FSOCIETY.BI_rango_etario values ('Entre 18 y 30 años',18, 30), ('Entre 31 y 50 años',31, 50), ('Mayor a 50 años',51, null)
	go
		
--Funcion que asigna rango etario
create function FSOCIETY.BI_asignar_rango_etario (@edad int)
returns int
begin
	declare @rango_etario_id int
		
	if(@edad < 31)
		begin
			select @rango_etario_id = r.rango_etario_id from FSOCIETY.BI_rango_etario r where @edad BETWEEN r.edad_inferior and r.edad_superior
		end
	else
		begin
			set @rango_etario_id = 3
		end
	return @rango_etario_id
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
	cliente_edad tinyint,
	rango_etario int
)
go

--Constraints
	alter table FSOCIETY.BI_cliente add constraint FK_cliente_rango_etario foreign key (rango_etario) references FSOCIETY.BI_rango_etario(rango_etario_id)
	go
		
	--Fill
	insert into FSOCIETY.BI_cliente
	select c.cliente_id, c.cliente_nombre, c.cliente_apellido, c.cliente_direccion, c.cliente_dni, c.cliente_mail, c.cliente_fecha_nac, c.cliente_sexo, DATEDIFF(yy, c.cliente_fecha_nac, GETDATE()) as edad, FSOCIETY.BI_asignar_rango_etario(DATEDIFF(yy, c.cliente_fecha_nac, GETDATE())) as rango_etario from FSOCIETY.Cliente c
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

/*
	Templates
	alter table FSOCIETY.BI_ add constraint FK_BI_AP_ foreign key () references FSOCIETY.BI_()
*/
/*
	DROPS

drop table FSOCIETY.BI_Venta_Autopartes
drop table FSOCIETY.BI_autoparte
drop table FSOCIETY.BI_factura
drop table FSOCIETY.BI_cliente
drop table FSOCIETY.BI_rango_etario
drop table FSOCIETY.BI_rubro_autoparte
drop table FSOCIETY.BI_fabricante_autoparte
drop table FSOCIETY.BI_sucursal
drop table FSOCIETY.BI_tiempo

drop function FSOCIETY.BI_asignar_rango_etario
*/