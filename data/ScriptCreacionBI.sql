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


	--Factura
	CREATE TABLE FSOCIETY.BI_factura(
		factura_nro_factura decimal(18,0) primary key,
		factura_sucursal int,
		factura_anio int,
		factura_mes int,
		factura_precio_facturado decimal(18,2),
		factura_cantidad_facturada decimal(18,0)
	)
	GO
		--Fill
		INSERT INTO FSOCIETY.BI_factura
		SELECT factura_nro_factura, fatura_sucursal, YEAR(factura_fecha), MONTH(factura_fecha), factura_precio_facturado, factura_cantidad_facturada
		FROM FSCOCIETY.Factura

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
		compra_precio_total decimal(18,2),
		compra_mes int,
		compra_anio int
	)
	go
		--Fill
		insert into FSOCIETY.BI_compra
		select c.compra_nro, c.compra_sucursal_id, c.compra_cliente_id, c.compra_tipo_compra, c.compra_precio_total, MONTH(c.compra_fecha), YEAR(c.compra_fecha) 
		from FSOCIETY.Compra c

	--Compra Automovil
	create table FSOCIETY.BI_compra_automovil(
		compra_auto_id int primary key,
		compra_auto_compra_nro decimal(18,0),
		compra_auto_automovil_id int,
		compra_auto_mes int,
		compra_auto_anio int,
	)
	go
		--Fill
		insert into FSOCIETY.BI_compra_automovil
		select ca.compra_auto_id, ca.compra_auto_compra_nro, ca.compra_auto_id, MONTH(c.compra_fecha), YEAR(c.compra_fecha) from FSOCIETY.Compra_Auto ca
			join FSOCIETY.Compra c on c.compra_nro = ca.compra_auto_compra_nro
		go

	--Venta Automovil
	create table FSOCIETY.BI_venta_automovil(
		venta_auto_id int primary key,
		venta_auto_auto_id int,
		venta_auto_precio_sin_iva decimal(18,2),
		venta_auto_precio_con_iva decimal(18,2),
		venta_auto_mes int,
		venta_auto_anio int
	)
	go
		--Fill
		insert into FSOCIETY.BI_venta_automovil
		select va.venta_auto_id, va.venta_auto_auto_id, va.venta_auto_precio_sin_iva, va.venta_auto_precio_con_iva, MONTH(f.factura_fecha), YEAR(f.factura_fecha) from FSOCIETY.Venta_Auto va
			join FSOCIETY.Factura f on f.factura_id = va.venta_auto_venta_id
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
	Rubro Autoparte				-> Listo
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
		compra_autoparte_cantidad int,
		compra_autoparte_mes int,
		compra_autoparte_anio int
	)
	go
		--Fill
		insert into FSOCIETY.BI_compra_autoparte
		select ca.compra_autoparte_id, ca.compra_autoparte_compra_id, ca.compra_autoparte_autoparte_id, ca.compra_autoparte_precio_unitario, ca.compra_autoparte_cantidad, MONTH(c.compra_fecha), YEAR(c.compra_fecha) from FSOCIETY.Compra_Autoparte ca
			join FSOCIETY.Compra c on c.compra_nro = ca.compra_autoparte_compra_id
		go

	create table FSOCIETY.BI_venta_autoparte(
		venta_autoparte_id int primary key,
		venta_autoparte_venta_id int,
		venta_autoparte_autoparte_id decimal(18,0),
		venta_autoparte_cantidad int,
		venta_autoparte_precio_unitario decimal(18,2),
		venta_autoparte_mes int,
		venta_autoparte_anio int
	)
	go
		--Fill
		insert into FSOCIETY.BI_venta_autoparte
		select va.venta_autoparte_id, va.venta_autoparte_venta_id, va.venta_autoparte_autoparte_id, va.venta_autoparte_cantidad, va.venta_autoparte_precio_unitario, MONTH(f.factura_fecha), YEAR(f.factura_fecha) from FSOCIETY.Venta_Autoparte va
			join FSOCIETY.Factura f on f.factura_id = va.venta_autoparte_venta_id
		go

		select * from FSOCIETY.Venta_Autoparte

/*
	drop table FSOCIETY.BI_autoparte
	drop table FSOCIETY.BI_rubro_autoparte
	drop table FSOCIETY.BI_compra_autoparte
	drop table FSOCIETY.BI_venta_autoparte
*/

/* -- CREACION DE TABLAS DE HECHOS -- */

	create table FSOCIETY.BI_Compra_Automoviles(
		compra_am_sucursal decimal(18,0) primary key,
		compra_compra decimal(18,0),
		compra_am_compra int
	)
	go

	alter table FSOCIETY.BI_Compra_Automoviles add constraint FK_compra_am_sucursal	foreign key (compra_am_sucursal) references FSOCIETY.BI_sucursal(sucursal_id)
	alter table FSOCIETY.BI_Compra_Automoviles add constraint FK_compra_compra		foreign key (compra_compra)		 references FSOCIETY.BI_compra(compra_nro)
	alter table FSOCIETY.BI_Compra_Automoviles add constraint FK_compra_am_compra	foreign key (compra_am_compra)	 references FSOCIETY.BI_compra_automovil(compra_auto_id)
	go

	create table FSOCIETY.BI_Venta_Automoviles(
		venta_am_sucursal decimal(18,0) primary key,
		venta_am_venta int
	)
	go

	alter table FSOCIETY.BI_Venta_Automoviles add constraint FK_venta_am_sucursal	foreign key (venta_am_sucursal)		references FSOCIETY.BI_sucursal(sucursal_id)
	alter table FSOCIETY.BI_Venta_Automoviles add constraint FK_venta_am_venta		foreign key (venta_am_venta)		references FSOCIETY.BI_factura(factura_nro_factura)
	go

	create table FSOCIETY.BI_Compra_Autopartes(
        compra_ap_compra int primary key,
        compra_ap_sucursal decimal(18,0)
    )
    alter table FSOCIETY.BI_Compra_Autopartes ADD CONSTRAINT FK_compra_ap_compra FOREIGN KEY (compra_ap_compra) REFERENCES FSOCIETY.BI_compra(compra_nro)
    alter table FSOCIETY.BI_Compra_Autopartes ADD CONSTRAINT FK_compra_ap_sucursal FOREIGN KEY (compra_ap_sucursal) REFERENCES FSOCIETY.BI_sucursal(sucursal_id)
    go

    create table FSOCIETY.BI_Venta_Autopartes(
        venta_ap_venta int primary key,
        venta_ap_sucursal decimal(18,0)
    )
    alter table FSOCIETY.BI_Venta_Autopartes ADD CONSTRAINT FK_venta_ap_venta FOREIGN KEY (venta_ap_venta) REFERENCES FSOCIETY.BI_Factura(factura_nro_factura)
    alter table FSOCIETY.BI_Venta_Autopartes ADD CONSTRAINT FK_venta_ap_sucursal FOREIGN KEY (venta_ap_sucursal) REFERENCES FSOCIETY.BI_sucursal(sucursal_id)
    go






/* REQUERIMIENTOS FUNCIONALES */
--Cantidad de automóviles, vendidos y comprados x sucursal y mes

select count(ca.compra_auto_id), ca.compra_auto_mes from FSOCIETY.BI_compra_automovil ca
	join FSOCIETY.BI_compra c on ca.compra_auto_compra_nro = c.compra_nro
	join FSOCIETY.BI_sucursal s on s.sucursal_id = c.compra_sucursal


--------------------------------------------------------------------------------------
-- Precio promedio de automóviles, vendidos y comprados.


