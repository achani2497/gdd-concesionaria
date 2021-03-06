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

	--Rango etario
	create table FSOCIETY.BI_rango_etario(
		rango_etario_id int identity(1,1) primary key,
		rango_etario_descripcion nvarchar(30),
		edad_inferior int,
		edad_superior int null
	)
	go 
		--Fill
		insert into FSOCIETY.BI_rango_etario values ('Entre 18 y 30 a�os',18, 30), ('Entre 31 y 50 a�os',31, 50), ('Mayor a 50 a�os',51, null)
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
		
	--Factura
	CREATE TABLE FSOCIETY.BI_factura(
		factura_nro_factura decimal(18,0) primary key,
		factura_sucursal int,
		factura_cliente_id int,
		factura_anio int,
		factura_mes int,
		factura_precio_facturado decimal(18,2),
		factura_cantidad_facturada decimal(18,0)
	)
	GO 
		--Constraints
		alter table FSOCIETY.BI_factura add constraint FK_BI_cliente_factura foreign key (factura_cliente_id) references FSOCIETY.BI_cliente(cliente_id)
		go

		--Fill
		insert into FSOCIETY.BI_factura
		select f.factura_nro_factura, f.factura_sucursal_id, f.factura_cliente_id, YEAR(f.factura_fecha), MONTH(f.factura_fecha), f.factura_precio_facturado, f.factura_cantidad_facturada
		from FSOCIETY.Factura f
		go

	--Potencia
	create table FSOCIETY.BI_potencia(
		codigo_potencia int identity(1,1) primary key,
		potencia_descripcion nvarchar(30),
		limite_inferior_potencia int,
		limite_superior_potencia int null
	)
	go
		--Fill
		insert into FSOCIETY.BI_potencia values ('Entre 50cv y 150cv', 50, 150), ('Entre 151cv y 300cv', 151, 300), ('Mas de 300cv', 300, null)
		go

	--Fabricante de auto
	create table FSOCIETY.BI_fabricante_auto(
		fabricante_codigo int primary key,
		fabricante_nombre nvarchar(255)
	)
	go 
		--Fill
		insert into FSOCIETY.BI_fabricante_auto
		select distinct f.fabricante_codigo, f.fabricante_nombre from FSOCIETY.Automovil a join FSOCIETY.Fabricante f on a.auto_fabricante_codigo = f.fabricante_codigo 
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


	-- Funcion para asignar un rango de potencia
	create function FSOCIETY.BI_asignar_rango_de_potencia(@potencia int)
	returns int
	begin
	
		declare @codigo_potencia int

		if(@potencia < 300)
			begin
				select @codigo_potencia = p.codigo_potencia from FSOCIETY.BI_potencia p where @potencia between p.limite_inferior_potencia and p.limite_superior_potencia
			end
		else
			begin
				set @codigo_potencia = 3
			end

		return @codigo_potencia
	end
	go

	--Modelo
	create table FSOCIETY.BI_modelo(
		modelo_codigo decimal(18,0) primary key,
		modelo_nombre nvarchar(255),
		modelo_rango_potencia int
	)
	go
		--Constraints
		alter table FSOCIETY.BI_modelo add constraint FK_BI_modelo_potencia foreign key (modelo_rango_potencia) references FSOCIETY.BI_potencia(codigo_potencia)
		go

		-- Fill
		insert into FSOCIETY.BI_modelo
		select m.modelo_codigo, m.modelo_nombre, FSOCIETY.BI_asignar_rango_de_potencia(m.modelo_potencia) as modelo_rango_potencia from FSOCIETY.Modelo m
		go
		
	--Automovil
	create table FSOCIETY.BI_automovil(
		auto_id int primary key,
		auto_modelo_codigo decimal(18, 0),
		auto_tipo_de_transmision decimal(18,0),
		auto_tipo_motor decimal(18,0),
		auto_tipo_caja decimal(18,0),
		auto_tipo_de_automovil decimal(18,0),
		auto_fabricante int,
		auto_nro_chasis nvarchar(50),
		auto_nro_motor nvarchar(50),
		auto_patente nvarchar(50)
	)
	go
		--Constraints
		alter table FSOCIETY.BI_automovil add constraint FK_BI_automovil_modelo foreign key (auto_modelo_codigo) references FSOCIETY.BI_modelo(modelo_codigo)
		alter table FSOCIETY.BI_automovil add constraint FK_BI_automovil_transmision foreign key (auto_tipo_de_transmision) references FSOCIETY.BI_tipo_de_transmision(tipo_transmision_codigo)
		alter table FSOCIETY.BI_automovil add constraint FK_BI_automovil_motor foreign key (auto_tipo_motor) references FSOCIETY.BI_tipo_de_motor(tipo_motor)
		alter table FSOCIETY.BI_automovil add constraint FK_BI_automovil_caja foreign key (auto_tipo_caja) references FSOCIETY.BI_tipo_de_caja(tipo_caja_codigo)
		alter table FSOCIETY.BI_automovil add constraint FK_BI_auto_moviltipo_auto foreign key (auto_tipo_de_automovil) references FSOCIETY.BI_tipo_de_automovil(tipo_auto_codigo)
		alter table FSOCIETY.BI_automovil add constraint FK_BI_auto_fabricante foreign key (auto_fabricante) references FSOCIETY.BI_fabricante_auto(fabricante_codigo)
		go
		
		--Fill
		insert into FSOCIETY.BI_automovil
		select a.auto_id, a.auto_modelo_codigo, a.auto_tipo_transmision_codigo, a.auto_tipo_motor, a.auto_tipo_caja_codigo, a.auto_tipo_auto, a.auto_fabricante_codigo, a.auto_nro_chasis, a.auto_nro_motor, a.auto_patente from FSOCIETY.Automovil a
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

	--Compra Automovil
	create table FSOCIETY.BI_compra_automovil(
		compra_auto_compra_nro decimal(18,0) primary key,
		compra_auto_automovil_id int,
		compra_auto_mes int,
		compra_auto_anio int,
		compra_auto_fecha datetime2(3)--Lo usamos para calcular el tiempo en stock de un modelo de automovil
	)
	go

		--Constraint
		alter table FSOCIETY.BI_compra_automovil add constraint FK_BI_auto_compra foreign key (compra_auto_automovil_id) references FSOCIETY.BI_automovil(auto_id)
		go

		--Fill
		insert into FSOCIETY.BI_compra_automovil
		select ca.compra_auto_compra_nro, ca.compra_auto_id, c.compra_mes, c.compra_anio, c.compra_fecha
		from FSOCIETY.Compra_Auto ca
			join FSOCIETY.BI_compra c on c.compra_nro = ca.compra_auto_compra_nro
		go

	--Venta Automovil
	create table FSOCIETY.BI_venta_automovil(
		venta_auto_nro_factura decimal(18,0) primary key,
		venta_auto_auto_id int,
		venta_auto_mes int,
		venta_auto_anio int,
		venta_auto_fecha datetime2(3)
	)
	go

		--Constraint
		alter table FSOCIETY.BI_venta_automovil add constraint FK_BI_auto_venta foreign key (venta_auto_auto_id) references FSOCIETY.BI_automovil(auto_id)
		go

		--Fill
		insert into FSOCIETY.BI_venta_automovil
		select va.venta_auto_factura_nro, va.venta_auto_auto_id, MONTH(f.factura_fecha), YEAR(f.factura_fecha), f.factura_fecha 
		from FSOCIETY.Venta_Auto va
			join FSOCIETY.Factura f on f.factura_nro_factura = va.venta_auto_factura_nro
		go

	--Autoparte
	create table FSOCIETY.BI_autoparte(
		autoparte_codigo decimal(18,0) primary key,
		autoparte_descripcion nvarchar(255),
		autoparte_fabricante int
	)
	go
		--Constraint
		alter table FSOCIETY.BI_autoparte add constraint FK_BI_autoparte_fabricante foreign key (autoparte_fabricante) references FSOCIETY.BI_fabricante_autoparte(fabricante_ap_codigo)
		go

		--Fill
		insert into FSOCIETY.BI_autoparte
		select a.autoparte_codigo, a.autoparte_descripcion, a.autoparte_fabricante_codigo from FSOCIETY.Auto_Parte a
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
		--Constraint
		alter table FSOCIETY.BI_compra_autoparte add constraint FK_BI_compra_ap_nro foreign key (compra_autoparte_compra_nro) references FSOCIETY.BI_compra(compra_nro)
		alter table FSOCIETY.BI_compra_autoparte add constraint FK_BI_compra_ap_ap_id foreign key (compra_autoparte_autoparte_id) references FSOCIETY.BI_autoparte(autoparte_codigo)
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
		--Constraints
		alter table FSOCIETY.BI_venta_autoparte add constraint FK_BI_vta_ap_factura foreign key (venta_autoparte_factura_nro) references FSOCIETY.factura(factura_nro_factura)
		alter table FSOCIETY.BI_venta_autoparte add constraint FK_BI_vta_ap_id foreign key (venta_autoparte_autoparte_id) references FSOCIETY.BI_autoparte(autoparte_codigo)
		go

		--Fill
		insert into FSOCIETY.BI_venta_autoparte
		select va.venta_autoparte_factura_nro, va.venta_autoparte_autoparte_id, va.venta_autoparte_cantidad, va.venta_autoparte_precio_unitario, MONTH(f.factura_fecha), YEAR(f.factura_fecha) from FSOCIETY.Venta_Autoparte va
			join FSOCIETY.Factura f on f.factura_nro_factura = va.venta_autoparte_factura_nro
		go




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











/* REQUERIMIENTOS FUNCIONALES SOBRE LOS AUTOS*/
--	****************** Cantidad de autom�viles, vendidos y comprados x sucursal y mes ******************

		--cant automoviles comprados x sucursal x mes x anio
		select count(distinct ca.compra_am_compra) as autos_comprados, s.sucursal_id, ca1.compra_auto_mes, ca1.compra_auto_anio 
		into #compras_sucursal_mes_anio
		from FSOCIETY.BI_Compra_Automoviles ca
			join FSOCIETY.BI_compra_automovil ca1 on ca.compra_am_compra = ca1.compra_auto_compra_nro
			join FSOCIETY.BI_sucursal s on s.sucursal_id = ca.compra_am_sucursal
		group by s.sucursal_id, ca1.compra_auto_mes, ca1.compra_auto_anio
		order by 2, 3
		go

		--cant automoviles vendidos x sucursal x mes x anio
		select count(distinct va.venta_am_venta) as autos_vendidos, s.sucursal_id, va1.venta_auto_mes, va1.venta_auto_anio
		into #ventas_sucursal_mes_anio
		from FSOCIETY.BI_Venta_Automoviles va
			join FSOCIETY.BI_venta_automovil va1 on va1.venta_auto_nro_factura = va.venta_am_venta
			join FSOCIETY.BI_sucursal s on va.venta_am_sucursal = s.sucursal_id
		group by s.sucursal_id, va1.venta_auto_mes, va1.venta_auto_anio
		order by 2, 3
		go

		-- Este cursor lo utilizo para poder llenar vista que junta toda la informacion
		declare group_compras_ventas_autos cursor for
			select v.sucursal_id, isnull(c.autos_comprados,0) as autos_comprados, v.autos_vendidos, v.venta_auto_mes, v.venta_auto_anio 
				from #ventas_sucursal_mes_anio v 
				left join #compras_sucursal_mes_anio c on c.sucursal_id = v.sucursal_id 
					and c.compra_auto_mes = v.venta_auto_mes 
					and c.compra_auto_anio = v.venta_auto_anio
		go

		-- Con este select creo la estructura de la tabla que voy a utilizar para hacer la vista que junta toda la informacion
		select top 0 v.sucursal_id, isnull(c.autos_comprados,0) as autos_comprados, v.autos_vendidos, v.venta_auto_mes as mes, v.venta_auto_anio as anio
		into FSOCIETY.BI_compras_ventas_autos
		from #ventas_sucursal_mes_anio v 
			left join #compras_sucursal_mes_anio c on c.sucursal_id = v.sucursal_id 
				and c.compra_auto_mes = v.venta_auto_mes 
				and c.compra_auto_anio = v.venta_auto_anio
		go

		-- Inserto todos los registros en la tabla que voy a utilizar para la view
		declare @sucursal_id int, @autos_comprados int, @autos_vendidos int, @mes int, @anio int
		open group_compras_ventas_autos
			fetch next from group_compras_ventas_autos into @sucursal_id, @autos_comprados, @autos_vendidos, @mes, @anio
				while (@@FETCH_STATUS = 0)
					begin
						insert into FSOCIETY.BI_compras_ventas_autos values (@sucursal_id, @autos_comprados, @autos_vendidos, @mes, @anio)

						fetch next from group_compras_ventas_autos into @sucursal_id, @autos_comprados, @autos_vendidos, @mes, @anio
					end
		close group_compras_ventas_autos
		deallocate group_compras_ventas_autos
		go

		-- View del reporte
		create view FSOCIETY_BI_VW_Reporte_compras_ventas_autos as
			select * from FSOCIETY.BI_compras_ventas_autos
		go

		drop table #compras_sucursal_mes_anio
		drop table #ventas_sucursal_mes_anio
		go

--	****************** Precio promedio de autom�viles, vendidos y comprados. ******************
	
		-- Precio promedio de autos comprados
		select CAST(avg(c.compra_precio_total) as decimal(18,2)) as precio_promedio_compra 
		into #precio_promedio_compra
		from FSOCIETY.BI_Compra_Automoviles ca
			join FSOCIETY.BI_compra c on c.compra_nro = ca.compra_am_compra
		go

		-- Precio promedio de autos vendidos
		select CAST(avg(f.factura_precio_facturado) as decimal(18,2)) as precio_promedio_venta 
		into #precio_promedio_venta
		from FSOCIETY.BI_Venta_Automoviles va
			join FSOCIETY.BI_factura f on f.factura_nro_factura = va.venta_am_venta
		go

		-- Con este select creo la tabla que voy a utilizar en la view
		select (select * from #precio_promedio_venta) as precio_promedio_venta, (select * from #precio_promedio_compra) as precio_promedio_compra 
		into FSOCIETY.BI_promedios_compra_venta_autos
		go
		
		-- View del reporte
		create view FSOCIETY_BI_VW_Reporte_precio_promedio_compra_venta_autos as
			select * from FSOCIETY.BI_promedios_compra_venta_autos
		go

		drop table #precio_promedio_compra
		drop table #precio_promedio_venta
		go

--	****************** Ganancias x Mes x Sucursal. ******************

		-- Monto total de compras por sucursal x mes x anio
		select sum(c.compra_precio_total) as total_mes, s.sucursal_id, ca1.compra_auto_mes, ca1.compra_auto_anio 
		into #total_compras_sucursal_mes_anio
		from FSOCIETY.BI_compra c 
			join FSOCIETY.BI_Compra_Automoviles ca on c.compra_nro = ca.compra_am_compra
			join FSOCIETY.BI_compra_automovil ca1 on ca1.compra_auto_compra_nro = ca.compra_am_compra
			join FSOCIETY.BI_sucursal s on s.sucursal_id = ca.compra_am_sucursal
		group by s.sucursal_id, ca1.compra_auto_mes, ca1.compra_auto_anio
		order by 2, 3
		go

		-- Monto total de ventas por sucursal x mes x anio
		select sum(f.factura_precio_facturado) as total_mes, s.sucursal_id, va1.venta_auto_mes, va1.venta_auto_anio 
		into #total_ventas_sucursal_mes_anio
		from FSOCIETY.Factura f
			join FSOCIETY.BI_Venta_Automoviles va on va.venta_am_venta = f.factura_nro_factura
			join FSOCIETY.BI_venta_automovil va1 on va1.venta_auto_nro_factura = va.venta_am_venta
			join FSOCIETY.BI_sucursal s on s.sucursal_id = va.venta_am_sucursal
		group by s.sucursal_id, va1.venta_auto_mes, va1.venta_auto_anio
		order by 2, 3
		go

		-- Con este select creo la estructura de la tabla que voy a utilizar para hacer la vista que junta toda la informacion
		select top 0 isnull(tv.total_mes,0) - isnull(tc.total_mes,0) as ganancia, tv.sucursal_id, tv.venta_auto_mes as mes, tv.venta_auto_anio as anio 
		into FSOCIETY.BI_ganancias_sucursal_mes
		from #total_compras_sucursal_mes_anio tc
			right join #total_ventas_sucursal_mes_anio tv on tc.sucursal_id = tv.sucursal_id and tc.compra_auto_mes = tv.venta_auto_mes and tc.compra_auto_anio = tv.venta_auto_anio
		order by 2, 3
		go

		-- Este cursor lo utilizo para poder llenar vista que junta toda la informacion
		declare cursor_ganancias_sucursal_mes cursor for
			select isnull(tv.total_mes,0) - isnull(tc.total_mes,0) as ganancia, tv.sucursal_id, tv.venta_auto_mes as mes, tv.venta_auto_anio as anio from #total_compras_sucursal_mes_anio tc
				right join #total_ventas_sucursal_mes_anio tv on tc.sucursal_id = tv.sucursal_id and tc.compra_auto_mes = tv.venta_auto_mes and tc.compra_auto_anio = tv.venta_auto_anio
			order by 2, 3
		go

		-- Inserto todos los registros en la tabla que voy a utilizar para la view
		open cursor_ganancias_sucursal_mes
		declare @ganancia decimal(18,0), @sucursal int, @mes int, @anio int
		fetch next from cursor_ganancias_sucursal_mes into @ganancia, @sucursal, @mes, @anio
		while(@@FETCH_STATUS = 0)
			begin
				insert into FSOCIETY.BI_ganancias_sucursal_mes values (@ganancia, @sucursal, @mes, @anio)

				fetch next from cursor_ganancias_sucursal_mes into @ganancia, @sucursal, @mes, @anio
			end
		go

		close cursor_ganancias_sucursal_mes
		deallocate cursor_ganancias_sucursal_mes
		go

		-- View del reporte
		create view FSOCIETY_BI_VW_Reporte_ganancias_autos as
			select * from FSOCIETY.BI_ganancias_sucursal_mes
		go

		drop table #total_compras_sucursal_mes_anio
		drop table #total_ventas_sucursal_mes_anio
		go

--	****************** Tiempo Promedio en Stock de cada modelo de automovil ******************
		
		--View del reporte
		create view FSOCIETY_BI_VW_Reporte_tiempo_promedio_en_stock_modelo as
			select  modelo_nombre, avg(DATEDIFF(dd, compra_fecha, venta_fecha)) as dias_promedio_stock from 
			(select m.modelo_nombre, ca.compra_auto_fecha as compra_fecha, isnull(va.venta_auto_fecha, getdate()) venta_fecha from FSOCIETY.BI_compra_automovil ca
				left join FSOCIETY.BI_venta_automovil va on va.venta_auto_auto_id = ca.compra_auto_automovil_id
				left join FSOCIETY.BI_Compra_Automoviles ca1 on ca1.compra_am_compra = ca.compra_auto_compra_nro
				left join FSOCIETY.BI_Venta_Automoviles va1 on va1.venta_am_venta = va.venta_auto_nro_factura
				join FSOCIETY.BI_automovil am on am.auto_id = ca.compra_auto_automovil_id
				join FSOCIETY.Modelo m on am.auto_modelo_codigo = m.modelo_codigo) modelo_fechas
			group by modelo_nombre
			go











/* REQUERIMIENTOS FUNCIONALES SOBRE LAS AUTOPARTES*/
-- ****************** Precio Promedio de cada autoparte, vendida y comprada ******************

		-- Precio promedio de venta de cada autoparte
		select cast(avg(f.factura_precio_facturado) as decimal(18,2)) as precio_promedio_venta, a.autoparte_codigo, a.autoparte_descripcion 
		into #precio_promedio_venta_autoparte
		from FSOCIETY.BI_factura f 
			join FSOCIETY.BI_Venta_Autopartes va on f.factura_nro_factura = va.venta_ap_venta_nro
			join FSOCIETY.BI_venta_autoparte va1 on va1.venta_autoparte_factura_nro = va.venta_ap_venta_nro
			join FSOCIETY.BI_autoparte a on va1.venta_autoparte_id = a.autoparte_codigo
		group by a.autoparte_codigo, a.autoparte_descripcion
		go

		-- Precio promedio de venta de cada autoparte
		select cast(avg(c.compra_precio_total) as decimal(18,2)) as precio_promedio_compra, a.autoparte_codigo, a.autoparte_descripcion 
		into #precio_promedio_compra_autoparte
		from FSOCIETY.BI_compra c
			join FSOCIETY.BI_Compra_Autopartes ca on ca.compra_ap_compra = c.compra_nro
			join FSOCIETY.BI_compra_autoparte ca1 on ca.compra_ap_compra = ca1.compra_autoparte_compra_nro
			join FSOCIETY.BI_autoparte a on ca1.compra_autoparte_id = a.autoparte_codigo
		group by a.autoparte_codigo, a.autoparte_descripcion
		go
 
		-- Con este select junto toda la informacion en una sola tabla
		select ca.autoparte_descripcion, ca.precio_promedio_compra, va.precio_promedio_venta 
		into FSOCIETY.BI_promedio_venta_compra_autopartes
		from #precio_promedio_compra_autoparte ca 
			join #precio_promedio_venta_autoparte va on ca.autoparte_codigo = va.autoparte_codigo
		go
		

		-- View del reporte
		create view FSOCIETY_BI_VW_Reporte_promedio_venta_compra_autoparte as
			select * from FSOCIETY.BI_promedio_venta_compra_autopartes
		go

		drop table #precio_promedio_compra_autoparte
		drop table #precio_promedio_venta_autoparte
		go

-- ****************** Ganancias x Mes x Sucursal. (AUTOPARTES) ******************

		-- Total vendido x sucursal x mes
		select sum(f.factura_precio_facturado) as total_facturado, s.sucursal_id, va1.venta_autoparte_mes, va1.venta_autoparte_anio 
		into #total_vendido_autoparte_sucursal_mes
		from FSOCIETY.BI_factura f
			join FSOCIETY.BI_Venta_Autopartes va on f.factura_nro_factura = va.venta_ap_venta_nro
			join FSOCIETY.BI_venta_autoparte va1 on va.venta_ap_venta_nro = va1.venta_autoparte_factura_nro
			join FSOCIETY.BI_sucursal s on s.sucursal_id = va.venta_ap_sucursal
		where f.factura_cantidad_facturada is not null
		group by s.sucursal_id, va1.venta_autoparte_mes, va1.venta_autoparte_anio
		order by 2, 3
		go

		-- Total comprado x sucursal x mes
		select sum(c.compra_precio_total) as total_gastado, s.sucursal_id, ca1.compra_autoparte_mes, ca1.compra_autoparte_anio 
		into #total_gastado_autoparte_sucursal_mes
		from FSOCIETY.BI_compra c
			join FSOCIETY.BI_Compra_Autopartes ca on c.compra_nro = ca.compra_ap_compra
			join FSOCIETY.BI_compra_autoparte ca1 on ca1.compra_autoparte_compra_nro = ca.compra_ap_compra
			join FSOCIETY.BI_sucursal s on s.sucursal_id = c.compra_sucursal
		where c.compra_tipo_compra like 'ap'
		group by s.sucursal_id, ca1.compra_autoparte_mes, ca1.compra_autoparte_anio
		order by 2, 3
		go

		--Ganancia x sucursal x mes
		select isnull(tv.total_facturado,0) - isnull(tg.total_gastado,0) as ganancia, tv.sucursal_id, tv.venta_autoparte_mes as mes, tv.venta_autoparte_anio as anio
		into FSOCIETY.BI_ganancias_autopartes_sucursal_mes
		from #total_gastado_autoparte_sucursal_mes tg
			right join #total_vendido_autoparte_sucursal_mes tv on tg.sucursal_id = tv.sucursal_id and tg.compra_autoparte_mes = tv.venta_autoparte_mes and tg.compra_autoparte_anio = tv.venta_autoparte_anio
		order by 2, 3
		go

		-- View del reporte
		create view FSOCIETY_BI_VW_Reporte_ganancias_autopartes as
			select * from FSOCIETY.BI_ganancias_autopartes_sucursal_mes
		go

		drop table #total_gastado_autoparte_sucursal_mes
		drop table #total_vendido_autoparte_sucursal_mes
		go

-- ****************** M�xima cantidad de stock por cada sucursal (anual) ******************

		-- Este select me da la cantidad total por autoparte que compraron las sucursales en distintos a�os
		select s.sucursal_id, ca1.compra_autoparte_autoparte_id, sum(ca1.compra_autoparte_cantidad) total_comprado, ca1.compra_autoparte_anio 
		into #total_ap_compradas_x_sucursal_x_anio
		from FSOCIETY.BI_Compra_Autopartes ca 
			join FSOCIETY.BI_compra_autoparte ca1 on ca.compra_ap_compra = ca1.compra_autoparte_compra_nro
			join FSOCIETY.BI_sucursal s on s.sucursal_id = ca.compra_ap_sucursal
		group by s.sucursal_id, ca1.compra_autoparte_autoparte_id, ca1.compra_autoparte_anio
		order by s.sucursal_id, ca1.compra_autoparte_autoparte_id
		go

		-- Este select me da la cantidad total por autoparte que vendieron las sucursales en distintos a�os
		select s.sucursal_id, va1.venta_autoparte_autoparte_id, sum(va1.venta_autoparte_cantidad) total_vendido, va1.venta_autoparte_anio 
		into #total_ap_vendidas_x_sucursal_x_anio
		from FSOCIETY.BI_Venta_Autopartes va 
			join FSOCIETY.BI_venta_autoparte va1 on va.venta_ap_venta_nro = va1.venta_autoparte_factura_nro
			join FSOCIETY.BI_sucursal s on s.sucursal_id = va.venta_ap_sucursal
		group by s.sucursal_id, va1.venta_autoparte_autoparte_id, va1.venta_autoparte_anio
		order by s.sucursal_id, va1.venta_autoparte_autoparte_id
		go

		-- Con este select meto el stock final en una tabla
		select v.sucursal_id, v.venta_autoparte_autoparte_id as autoparte_id, (isnull(c.total_comprado, 0) - isnull(v.total_vendido,0)) as stock, v.venta_autoparte_anio as anio 
		into FSOCIETY.BI_stock_sucursal_anio
		from #total_ap_vendidas_x_sucursal_x_anio v 
			left join #total_ap_compradas_x_sucursal_x_anio c on 
				v.sucursal_id = c.sucursal_id and 
				v.venta_autoparte_autoparte_id = c.compra_autoparte_autoparte_id and
				v.venta_autoparte_anio = c.compra_autoparte_anio
		order by v.sucursal_id, autoparte_id, v.venta_autoparte_anio
		go

		--Vista del Reporte
		create view FSOCIETY_BI_VW_Reporte_stock_x_sucursal_anio as
			select * from FSOCIETY.BI_stock_sucursal_anio
		go

		drop table #total_ap_vendidas_x_sucursal_x_anio
		drop table #total_ap_compradas_x_sucursal_x_anio
		go

/* SELECTS PARA MOSTRAR LAS METRICAS QUE NOS PIDEN LOS REQUERIMIENTOS */
	
	/*
		-- Reporte de compras y ventas x sucursal x mes x anio
		select * from FSOCIETY_BI_VW_Reporte_compras_ventas_autos order by sucursal_id, mes

		-- Reporte de Precio promedio de compra y de venta de los autos
		select * from FSOCIETY_BI_VW_Reporte_precio_promedio_compra_venta_autos

		-- Reporte de ganancias por parte de los autos x sucursal x mes x anio
		select * from FSOCIETY_BI_VW_Reporte_ganancias_autos

		-- Reporte de tiempo promedio en stock segun modelo 
		select * from FSOCIETY_BI_VW_Reporte_tiempo_promedio_en_stock_modelo order by modelo_nombre

		-- Reporte del precio promedio de compra y de venta por autoparte
		select * from FSOCIETY_BI_VW_Reporte_promedio_venta_compra_autoparte
		
		-- Reporte de ganancias por parte de los autopartes x sucursal x mes x anio
		select * from FSOCIETY_BI_VW_Reporte_ganancias_autopartes order by sucursal_id, mes
		
		-- Reporte de stock maximo de autoparte x sucursal x anio
		select * from FSOCIETY_BI_VW_Reporte_stock_x_sucursal_anio order by sucursal_id, autoparte_id, anio
	*/

/* DROPS */
/*
	drop table FSOCIETY.BI_venta_automovil
	drop table FSOCIETY.BI_rubro_autoparte
	drop table FSOCIETY.BI_compra_autoparte
	drop table FSOCIETY.BI_venta_autoparte
	drop table FSOCIETY.BI_autoparte
	drop table FSOCIETY.BI_fabricante_autoparte
	drop table FSOCIETY.BI_Compra_Automoviles
	drop table FSOCIETY.BI_Compra_Autopartes
	drop table FSOCIETY.BI_Venta_Automoviles
	drop table FSOCIETY.BI_Venta_Autopartes
	drop table FSOCIETY.BI_sucursal
	drop table FSOCIETY.BI_factura
	drop table FSOCIETY.BI_compra
	drop table FSOCIETY.BI_compra_automovil
	drop table FSOCIETY.BI_automovil
	drop table FSOCIETY.BI_modelo
	drop table FSOCIETY.BI_fabricante_auto
	drop table FSOCIETY.BI_tipo_de_automovil
	drop table FSOCIETY.BI_tipo_de_caja
	drop table FSOCIETY.BI_tipo_de_motor
	drop table FSOCIETY.BI_tipo_de_transmision
	drop table FSOCIETY.BI_potencia
	drop table FSOCIETY.BI_cliente
	drop table FSOCIETY.BI_rango_etario
	
	drop table FSOCIETY.BI_promedios_compra_venta_autos
	drop table FSOCIETY.BI_compras_ventas_autos
	drop table FSOCIETY.BI_ganancias_sucursal_mes
	drop table FSOCIETY.BI_promedio_venta_compra_autopartes
	drop table FSOCIETY.BI_ganancias_autopartes_sucursal_mes
	drop table FSOCIETY.BI_stock_sucursal_anio

	drop function FSOCIETY.BI_asignar_rango_de_potencia
	drop function FSOCIETY.BI_asignar_rango_etario

	drop view BI_Reporte_compras_ventas_autos
	drop view BI_Reporte_precio_promedio_compra_venta_autos
	drop view BI_Reporte_ganancias_autos
	drop view BI_Reporte_tiempo_promedio_en_stock_modelo
	drop view BI_Reporte_promedio_venta_compra_autoparte
	drop view BI_Reporte_ganancias_autopartes
	drop view BI_Reporte_stock_x_sucursal_anio
	
*/

