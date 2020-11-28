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
		SELECT factura_nro_factura, factura_sucursal_id, YEAR(factura_fecha), MONTH(factura_fecha), factura_precio_facturado, factura_cantidad_facturada
		FROM FSOCIETY.Factura
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
		compra_precio_total decimal(18,2),
		compra_mes int,
		compra_anio int
	)
	go
		--Fill
		insert into FSOCIETY.BI_compra
		select c.compra_nro, c.compra_sucursal_id, c.compra_cliente_id, c.compra_tipo_compra, c.compra_precio_total, MONTH(c.compra_fecha), YEAR(c.compra_fecha) 
		from FSOCIETY.Compra c
		go

	--Compra Automovil
	create table FSOCIETY.BI_compra_automovil(
		compra_auto_compra_nro decimal(18,0) primary key,
		compra_auto_automovil_id int,
		compra_auto_mes int,
		compra_auto_anio int,
	)
	go
		--Fill
		insert into FSOCIETY.BI_compra_automovil
		select ca.compra_auto_compra_nro, ca.compra_auto_id, c.compra_mes, c.compra_anio 
		from FSOCIETY.Compra_Auto ca
			join FSOCIETY.BI_compra c on c.compra_nro = ca.compra_auto_compra_nro
		go

	--Venta Automovil
	create table FSOCIETY.BI_venta_automovil(
		venta_auto_nro_factura decimal(18,0) primary key,
		venta_auto_auto_id int,
		venta_auto_precio_sin_iva decimal(18,2),
		venta_auto_precio_con_iva decimal(18,2),
		venta_auto_mes int,
		venta_auto_anio int
	)
	go
		--Fill
		insert into FSOCIETY.BI_venta_automovil
		select va.venta_auto_factura_nro, va.venta_auto_auto_id, va.venta_auto_precio_sin_iva, va.venta_auto_precio_con_iva, MONTH(f.factura_fecha), YEAR(f.factura_fecha) from FSOCIETY.Venta_Auto va
			join FSOCIETY.Factura f on f.factura_nro_factura = va.venta_auto_factura_nro
		go
/*
	drop table FSOCIETY.BI_cliente
	drop table FSOCIETY.BI_fabricante_auto
	drop table FSOCIETY.BI_modelo
	drop table FSOCIETY.BI_sucursal
	drop table FSOCIETY.BI_factura
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
		compra_autoparte_compra_nro decimal(18,0),
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

	--Venta Autoparte
	create table FSOCIETY.BI_venta_autoparte(
		venta_autoparte_id int identity(1,1) primary key,
		venta_autoparte_factura_nro decimal(18,0),
		venta_autoparte_autoparte_id decimal(18,0),
		venta_autoparte_cantidad int,
		venta_autoparte_precio_unitario decimal(18,2),
		venta_autoparte_mes int,
		venta_autoparte_anio int
	)
	go
		--Fill
		insert into FSOCIETY.BI_venta_autoparte
		select va.venta_autoparte_factura_nro, va.venta_autoparte_autoparte_id, va.venta_autoparte_cantidad, va.venta_autoparte_precio_unitario, MONTH(f.factura_fecha), YEAR(f.factura_fecha) from FSOCIETY.Venta_Autoparte va
			join FSOCIETY.Factura f on f.factura_nro_factura = va.venta_autoparte_factura_nro
		go

/*
	drop table FSOCIETY.BI_autoparte
	drop table FSOCIETY.BI_rubro_autoparte
	drop table FSOCIETY.BI_compra_autoparte
	drop table FSOCIETY.BI_venta_autoparte
*/

/* -- CREACION DE TABLAS DE HECHOS -- */

	-- Hecho Compra Automovil
	create table FSOCIETY.BI_Compra_Automoviles(
		compra_am_sucursal int,
		compra_am_compra decimal(18,0),
		primary key(compra_am_sucursal, compra_am_compra)
	)
	go

		--Constraints
		alter table FSOCIETY.BI_Compra_Automoviles add constraint FK_compra_am_sucursal	foreign key (compra_am_sucursal) references FSOCIETY.BI_sucursal(sucursal_id)
		alter table FSOCIETY.BI_Compra_Automoviles add constraint FK_compra_am_compra	foreign key (compra_am_compra)	 references FSOCIETY.BI_compra_automovil(compra_auto_compra_nro)
		go

		--Fill
		insert into FSOCIETY.BI_Compra_Automoviles
		select c.compra_sucursal, ca.compra_auto_compra_nro from FSOCIETY.BI_compra c
			join FSOCIETY.BI_compra_automovil ca on c.compra_nro = ca.compra_auto_compra_nro
		order by c.compra_sucursal
		go

	--Hecho Venta Automovil
	create table FSOCIETY.BI_Venta_Automoviles(
		venta_am_sucursal int,
		venta_am_venta decimal(18,0),
		primary key (venta_am_sucursal, venta_am_venta)
	)
	go

		--Constraints
		alter table FSOCIETY.BI_Venta_Automoviles add constraint FK_venta_am_sucursal	foreign key (venta_am_sucursal)		references FSOCIETY.BI_sucursal(sucursal_id)
		alter table FSOCIETY.BI_Venta_Automoviles add constraint FK_venta_am_venta		foreign key (venta_am_venta)		references FSOCIETY.BI_factura(factura_nro_factura)
		go

		--Fill
		insert into FSOCIETY.BI_Venta_Automoviles
		select f.factura_sucursal, va.venta_auto_nro_factura from FSOCIETY.BI_factura f
			join FSOCIETY.BI_venta_automovil va on va.venta_auto_nro_factura = f.factura_nro_factura
		order by f.factura_sucursal
		go

	--Hecho Compra Autoparte
	create table FSOCIETY.BI_Compra_Autopartes(
        compra_ap_compra decimal(18,0),
        compra_ap_sucursal int,
		primary key (compra_ap_compra, compra_ap_sucursal)
    )
	go

		--Constraints
		alter table FSOCIETY.BI_Compra_Autopartes ADD CONSTRAINT FK_compra_ap_compra FOREIGN KEY (compra_ap_compra) REFERENCES FSOCIETY.BI_compra(compra_nro)
		alter table FSOCIETY.BI_Compra_Autopartes ADD CONSTRAINT FK_compra_ap_sucursal FOREIGN KEY (compra_ap_sucursal) REFERENCES FSOCIETY.BI_sucursal(sucursal_id)
		go

		--Fill
		insert into FSOCIETY.BI_Compra_Autopartes
		select distinct ca.compra_autoparte_compra_nro, c.compra_sucursal from FSOCIETY.BI_compra c
			join FSOCIETY.BI_compra_autoparte ca on c.compra_nro = ca.compra_autoparte_compra_nro
		order by c.compra_sucursal
		go

	--Hecho Venta Autoparte
    create table FSOCIETY.BI_Venta_Autopartes(
        venta_ap_venta_nro decimal(18,0),
        venta_ap_sucursal int
    )
	go
	
		--Constraints
		alter table FSOCIETY.BI_Venta_Autopartes ADD CONSTRAINT FK_venta_ap_venta FOREIGN KEY (venta_ap_venta_nro) REFERENCES FSOCIETY.BI_Factura(factura_nro_factura)
		alter table FSOCIETY.BI_Venta_Autopartes ADD CONSTRAINT FK_venta_ap_sucursal FOREIGN KEY (venta_ap_sucursal) REFERENCES FSOCIETY.BI_sucursal(sucursal_id)
		go

		--Fill
		insert into FSOCIETY.BI_Venta_Autopartes
		select distinct va.venta_autoparte_factura_nro, f.factura_sucursal from FSOCIETY.BI_factura f
			join FSOCIETY.BI_venta_autoparte va on va.venta_autoparte_factura_nro = f.factura_nro_factura
		order by f.factura_sucursal
		go

/*
	drop table FSOCIETY.BI_Compra_Automoviles
	drop table FSOCIETY.BI_Compra_Autopartes
	drop table FSOCIETY.BI_Venta_Automoviles
	drop table FSOCIETY.BI_Venta_Autopartes
*/



/* REQUERIMIENTOS FUNCIONALES */
-- ****************** Cantidad de automóviles, vendidos y comprados x sucursal y mes ******************

	--cant automoviles comprados x sucursal x mes x anio
	select count(distinct ca.compra_am_compra) as autos_comprados, s.sucursal_id, ca1.compra_auto_mes, ca1.compra_auto_anio 
	into #compras_sucursal_mes_anio
	from FSOCIETY.BI_Compra_Automoviles ca
		join FSOCIETY.BI_compra_automovil ca1 on ca.compra_am_compra = ca1.compra_auto_compra_nro
		join FSOCIETY.BI_sucursal s on s.sucursal_id = ca.compra_am_sucursal
	group by s.sucursal_id, ca1.compra_auto_mes, ca1.compra_auto_anio
	order by 2, 3

	--cant automoviles vendidos x sucursal x mes x anio
	select count(distinct va.venta_am_venta) as autos_vendidos, s.sucursal_id, va1.venta_auto_mes, va1.venta_auto_anio
	into #ventas_sucursal_mes_anio
	from FSOCIETY.BI_Venta_Automoviles va
		join FSOCIETY.BI_venta_automovil va1 on va1.venta_auto_nro_factura = va.venta_am_venta
		join FSOCIETY.BI_sucursal s on va.venta_am_sucursal = s.sucursal_id
	group by s.sucursal_id, va1.venta_auto_mes, va1.venta_auto_anio
	order by 2, 3

	--drop table #compras_sucursal_mes_anio
	--drop table #ventas_sucursal_mes_anio

-- ****************** Precio promedio de automóviles, vendidos y comprados. ******************
	
	-- Precio promedio de autos comprados
	select CAST(avg(c.compra_precio_total) as decimal(18,2)) as precio_promedio_compra 
	into #precio_promedio_compra
	from FSOCIETY.BI_Compra_Automoviles ca
		join FSOCIETY.BI_compra c on c.compra_nro = ca.compra_am_compra

	-- Precio promedio de autos vendidos
	select CAST(avg(f.factura_precio_facturado) as decimal(18,2)) as precio_promedio_venta 
	into #precio_promedio_venta
	from FSOCIETY.BI_Venta_Automoviles va
		join FSOCIETY.BI_factura f on f.factura_nro_factura = va.venta_am_venta

	--drop table #precio_promedio_compra
	--drop table #precio_promedio_venta

-- ****************** Ganancias x Mes x Sucursal. ******************

	-- Monto total de compras por sucursal x mes x anio
	select sum(c.compra_precio_total) as total_mes, s.sucursal_id, ca1.compra_auto_mes, ca1.compra_auto_anio 
	into #total_compras_sucursal_mes_anio
	from FSOCIETY.BI_compra c 
		join FSOCIETY.BI_Compra_Automoviles ca on c.compra_nro = ca.compra_am_compra
		join FSOCIETY.BI_compra_automovil ca1 on ca1.compra_auto_compra_nro = ca.compra_am_compra
		join FSOCIETY.BI_sucursal s on s.sucursal_id = ca.compra_am_sucursal
	group by s.sucursal_id, ca1.compra_auto_mes, ca1.compra_auto_anio
	order by 2, 3

	-- Monto total de ventas por sucursal x mes x anio
	select sum(f.factura_precio_facturado) as total_mes, s.sucursal_id, va1.venta_auto_mes, va1.venta_auto_anio 
	into #total_ventas_sucursal_mes_anio
	from FSOCIETY.Factura f
		join FSOCIETY.BI_Venta_Automoviles va on va.venta_am_venta = f.factura_nro_factura
		join FSOCIETY.BI_venta_automovil va1 on va1.venta_auto_nro_factura = va.venta_am_venta
		join FSOCIETY.BI_sucursal s on s.sucursal_id = va.venta_am_sucursal
	group by s.sucursal_id, va1.venta_auto_mes, va1.venta_auto_anio
	order by 2, 3

	select isnull(tv.total_mes,0) - isnull(tc.total_mes,0) as ganancia, tv.sucursal_id, tv.venta_auto_mes, tv.venta_auto_anio from #total_compras_sucursal_mes_anio tc
		right join #total_ventas_sucursal_mes_anio tv on tc.sucursal_id = tv.sucursal_id and tc.compra_auto_mes = tv.venta_auto_mes and tc.compra_auto_anio = tv.venta_auto_anio
	order by 2, 3
