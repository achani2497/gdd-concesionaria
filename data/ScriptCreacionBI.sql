use [GD2C2020]
go

/*Creacion del Schema*/
if(not exists(select * from sys.schemas where NAME = 'FSOCIETY'))
	begin
		exec('create schema[FSOCIETY]')
		print 'Creacion de Schema lista'
	end
go

/*Creacion de las dimensiones*/

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
		cliente_edad tinyint
	)
	go
		--Fill
		insert into FSOCIETY.BI_cliente
		select c.cliente_id, c.cliente_nombre, c.cliente_apellido, c.cliente_direccion, c.cliente_dni, c.cliente_mail, c.cliente_fecha_nac, c.cliente_sexo, DATEDIFF(yy, c.cliente_fecha_nac, GETDATE()) from FSOCIETY.Cliente c
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

	--Modelo
	create table FSOCIETY.BI_modelo(
		modelo_codigo decimal(18,0),
		modelo_nombre nvarchar(255),
		modelo_potencia decimal(18,0)
	)
	go
		-- Fill
		insert into FSOCIETY.BI_modelo
		select * from FSOCIETY.Modelo
		go

	--Fabricante
	create table FSOCIETY.BI_fabricante_auto(
		fabricante_codigo int primary key,
		fabricante_nombre nvarchar(255)
	)
	go
		--Fill
		insert into FSOCIETY.BI_fabricante_auto
		select * from FSOCIETY.Fabricante
		go

	--Tipo de Automovil
	create table FSOCIETY.BI_tipo_de_automovil(
		tipo_auto_codigo decimal(18,0) primary key,
		tipo_auto_desc nvarchar(255)
	)
	go
		--Fill
		insert into FSOCIETY.BI_tipo_de_automovil
		select * from FSOCIETY.Tipo_Auto
		go

	--Tipo de caja de cambios
	create table FSOCIETY.BI_tipo_de_caja(
		tipo_caja_codigo decimal(18,0) primary key,
		tipo_caja_descripcion nvarchar(255)
	)
	go
		--Fill
		insert into FSOCIETY.BI_tipo_de_caja
		select * from FSOCIETY.Tipo_Caja
		go

	--Tipo de motor
	create table FSOCIETY.BI_tipo_de_motor(
		tipo_motor decimal(18,0) primary key,
		tipo_moto_descripcion nvarchar(255)
	)
	go
		--Fill
		insert into FSOCIETY.BI_tipo_de_motor
		select * from FSOCIETY.Tipo_Motor
		go

	--Tipo de transmision
	create table FSOCIETY.BI_tipo_de_transmision(
		tipo_transmision_codigo decimal(18,0) primary key,
		tipo_transmision_descripcion nvarchar(255)
	)
	go
		--Fill
		insert into FSOCIETY.BI_tipo_de_transmision
		select * from FSOCIETY.Tipo_Transmision
		go

	--Potencia

	create table FSOCIETY.BI_compra(
		compra_nro decimal(18,0) primary key,
		compra_sucursal int,
		compra_cliente_id int,
		compra_tipo_compra nchar(2),
		compra_fecha datetime2(3),
		compra_precio_total decimal(18,2)
	)
	go
	--Compra Automovil
	create table FSOCIETY.BI_compra_automovil(
		compra_auto_id int identity(1,1) primary key,
		compra_auto_compra_nro decimal(18,0),
		compra_auto_automovil_id int
	)
	go
		--Fill
		insert into FSOCIETY.BI_compra_automovil
		select * from FSOCIETY.Compra_Auto
		go

	--Venta Automovil
	create table FSOCIETY.BI_venta_automovil(
		venta_auto_id int primary key,
		venta_auto_auto_id int,
		venta_auto_precio_sin_iva decimal(18,2),
		venta_auto_precio_con_iva decimal(18,2)
	)
	go
		--Fill
		insert into FSOCIETY.BI_venta_automovil
		select * from FSOCIETY.Venta_Auto
		go
/*
	drop table FSOCIETY.BI_cliente
	drop table FSOCIETY.BI_fabricante_auto
	drop table FSOCIETY.BI_modelo
	drop table FSOCIETY.BI_sucursal
	drop table FSOCIETY.BI_tipo_de_automovil
	drop table FSOCIETY.BI_tipo_de_caja
	drop table FSOCIETY.BI_tipo_de_motor
	drop table FSOCIETY.BI_tipo_de_transmision
	drop table FSOCIETY.BI_compra
	drop table FSOCIETY.BI_compra_automovil
	drop table FSOCIETY.BI_venta_automovil
*/

--dimensiones para compra / venta de automoviles:
/*
	Tiempo (año y mes)			-> Lo saco de las compras de autos
	Sucursal					-> Listo
	Modelo						-> Listo
	Fabricante					-> Listo
	Tipo de Automovil			-> Listo
	Tipo caja de cambios		-> Listo
	Tipo motor					-> Listo
	Tipo transmision			-> Listo
	Potencia					-> ? ? ?
*/

--dimensiones para compra / venta de autopartes:
/*
	Tiempo						-> Lo saco de las compras de las autopartes
	Sucursal					-> Listo
	Autoparte					-> Listo
	Rubro Autoparte				-> Listo la creacion de la dimension, falta el llenado
	Fabricante					-> Listo
*/

	--Autoparte
	create table FSOCIETY.BI_autoparte(
		autoparte_codigo decimal(18,0) primary key,
		autoparte_descripcion nvarchar(255)
	)
	go
		--Fill
		insert into FSOCIETY.BI_autoparte
		select a.autoparte_codigo, a.autoparte_descripcion from FSOCIETY.Auto_Parte a
		go

	--Rubro Autoparte
	create table FSOCIETY.BI_rubro_autoparte(
		rubro_codigo int identity(1,1) primary key,
		rubro_descripcion nvarchar(50)
	)
	go
		--Fill
		insert into FSOCIETY.BI_rubro_autoparte
		select a.autoparte_rubro from FSOCIETY.Auto_Parte a
		go

	--Compra Autoparte
	create table FSOCIETY.BI_compra_autoparte(
		compra_autoparte_id int primary key,
		compra_autoparte_compra_id decimal(18,0),
		compra_autoparte_autoparte_id decimal(18,0),
		compra_autoparte_precio_unitario decimal(18,2),
		compra_autoparte_cantidad int
	)
	go
		--Fill
		insert into FSOCIETY.BI_compra_autoparte
		select * from FSOCIETY.Compra_Autoparte
		go

	create table FSOCIETY.BI_venta_autoparte(
		venta_autoparte_id int primary key,
		venta_autoparte_venta_id int,
		venta_autoparte_autoparteid decimal(18,0),
		venta_autoparte_cantidad int,
		venta_autoparte_precio_unitario decimal(18,2),
		venta_autoparte_fecha datetime2(3)
	)
	go
		--Fill
		insert into FSOCIETY.BI_venta_autoparte
		select * from FSOCIETY.Venta_Autoparte

/*
	drop table FSOCIETY.BI_autoparte
	drop table FSOCIETY.BI_rubro_autoparte
	drop table FSOCIETY.BI_compra_autoparte
	drop table FSOCIETY.BI_venta_autoparte
*/

/* -- Creacion de Tablas de Hechos -- */

	create table FSOCIETY.BI_Compra_Automoviles(
		compra_am_sucursal decimal(18,0) primary key,

	)
	go
	create table FSOCIETY.BI_Venta_Automoviles(
		--TODO:
	)
	go
	create table FSOCIETY.BI_Compra_Autopartes(
		--TODO:
	)
	go
	create table FSOCIETY.BI_Venta_Autopartes(
		--TODO:
	)
	go