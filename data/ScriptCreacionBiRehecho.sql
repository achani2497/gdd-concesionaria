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

	--Fill
	insert into FSOCIETY.BI_autoparte
	select a.autoparte_codigo, a.autoparte_descripcion, 1, a.autoparte_fabricante_codigo from FSOCIETY.Auto_Parte a
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
		
		--Fill
		insert into FSOCIETY.BI_automovil
		select a.auto_id, a.auto_modelo_codigo, a.auto_tipo_transmision_codigo, a.auto_tipo_motor, a.auto_tipo_caja_codigo, a.auto_tipo_auto, a.auto_fabricante_codigo, a.auto_nro_chasis, a.auto_nro_motor, a.auto_patente from FSOCIETY.Automovil a
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

-- Funcion para asignar el codigo de potencia
	create function FSOCIETY.BI_asignar_potencia(@potencia int)
returns int
begin
	
	declare @codigo_potencia int
	select @codigo_potencia = p.codigo_potencia from FSOCIETY.BI_potencia p where @potencia between p.limite_inferior_potencia and p.limite_superior_potencia
	
	if (@codigo_potencia is null )
		set @codigo_potencia = 3
	
	return @codigo_potencia

end
	go

--Modelo
create table FSOCIETY.BI_modelo(
	modelo_codigo decimal(18,0) primary key,
	modelo_nombre nvarchar(255),
	modelo_potencia int
)
go
	
	-- Fill
	insert into FSOCIETY.BI_modelo
	select m.modelo_codigo, m.modelo_nombre, m.modelo_potencia as modelo_rango_potencia from FSOCIETY.Modelo m
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




/* CREACION DE TABLAS DE HECHOS */

	-- VENTA DE AUTOPARTES
	create table FSOCIETY.BI_Venta_Autoparte(
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
		-- Constraint
		alter table FSOCIETY.BI_Venta_Autoparte add constraint FK_BI_VAP_tiempo foreign key (tiempo_id) references FSOCIETY.BI_tiempo(tiempo_id)	
		alter table FSOCIETY.BI_Venta_Autoparte add constraint FK_BI_VAP_cliente foreign key (cliente) references FSOCIETY.BI_cliente(cliente_id)
		alter table FSOCIETY.BI_Venta_Autoparte add constraint FK_BI_VAP_factura foreign key (factura) references FSOCIETY.BI_Factura(factura_nro_factura)
		alter table FSOCIETY.BI_Venta_Autoparte add constraint FK_BI_VAP_sucursal foreign key (sucursal) references FSOCIETY.BI_sucursal(sucursal_id)
		alter table FSOCIETY.BI_Venta_Autoparte add constraint FK_BI_VAP_fabricante foreign key (fabricante) references FSOCIETY.BI_fabricante_autoparte(fabricante_ap_codigo)
		alter table FSOCIETY.BI_Venta_Autoparte add constraint FK_BI_VAP_rubro_autoparte foreign key (rubro_autoparte) references FSOCIETY.BI_rubro_autoparte(rubro_codigo)
		alter table FSOCIETY.BI_Venta_Autoparte add constraint FK_BI_VAP_autoparte foreign key (autoparte) references FSOCIETY.BI_autoparte(autoparte_codigo)
		go

		-- Fill
		insert into FSOCIETY.BI_Venta_Autoparte
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
	create table FSOCIETY.BI_Compra_Autoparte(
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
		alter table FSOCIETY.BI_Compra_Autoparte add constraint FK_BI_CAP_tiempo foreign key (tiempo_id) references FSOCIETY.BI_Tiempo(tiempo_id)
		alter table FSOCIETY.BI_Compra_Autoparte add constraint FK_BI_CAP_compra foreign key (compra) references FSOCIETY.BI_compra(compra_nro)
		alter table FSOCIETY.BI_Compra_Autoparte add constraint FK_BI_CAP_sucursal foreign key (sucursal) references FSOCIETY.BI_sucursal(sucursal_id)
		alter table FSOCIETY.BI_Compra_Autoparte add constraint FK_BI_CAP_fabricante foreign key (fabricante) references FSOCIETY.BI_fabricante_autoparte(fabricante_ap_codigo)
		alter table FSOCIETY.BI_Compra_Autoparte add constraint FK_BI_CAP_rubro foreign key (rubro_autoparte) references FSOCIETY.BI_rubro_autoparte(rubro_codigo)
		alter table FSOCIETY.BI_Compra_Autoparte add constraint FK_BI_CAP_autoparte foreign key (autoparte) references FSOCIETY.BI_autoparte(autoparte_codigo)
		go
	
		-- Fill
		insert into FSOCIETY.BI_Compra_Autoparte
		select t.tiempo_id, co.compra_nro, s.sucursal_id, ap.autoparte_codigo, fap.fabricante_ap_codigo, rap.rubro_codigo, ca.compra_autoparte_cantidad, ca.compra_autoparte_precio_unitario
		from FSOCIETY.BI_compra co
			join FSOCIETY.BI_Tiempo t on co.compra_anio = t.anio and co.compra_mes = t.mes
			join FSOCIETY.BI_sucursal s on co.compra_sucursal = s.sucursal_id
			join FSOCIETY.Compra_Autoparte ca on co.compra_nro = ca.compra_autoparte_compra_id
			join FSOCIETY.BI_autoparte ap on ca.compra_autoparte_autoparte_id = ap.autoparte_codigo
			join FSOCIETY.BI_fabricante_autoparte fap on ap.autoparte_fabricante = fap.fabricante_ap_codigo
			join FSOCIETY.BI_rubro_autoparte rap on rap.rubro_codigo = ap.autoparte_rubro 
		go



	-- VENTA DE AUTOS
	create table FSOCIETY.BI_Venta_Automovil(
		tiempo_id int,
		cliente int,
		factura decimal(18,0),
		sucursal int,
		automovil int,
		modelo decimal(18,0),
		fabricante int,
		tipo_de_auto decimal(18,0),
		tipo_caja decimal(18,0),
		tipo_motor decimal(18,0),
		tipo_transmision decimal(18,0),
		potencia int,
		precio_con_iva decimal(18,2),
		precio_sin_iva decimal(18,2)
	)
	go

		-- Constraints
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_tiempo foreign key (tiempo_id) references FSOCIETY.BI_Tiempo(tiempo_id)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_cliente foreign key (cliente) references FSOCIETY.BI_cliente(cliente_id)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_factura foreign key (factura) references FSOCIETY.BI_factura(factura_nro_factura)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_sucursal foreign key (sucursal) references FSOCIETY.BI_sucursal(sucursal_id)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_automovil foreign key (automovil) references FSOCIETY.BI_automovil(auto_id)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_modelo foreign key (modelo) references FSOCIETY.BI_modelo(modelo_codigo)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_fabricante foreign key (fabricante) references FSOCIETY.BI_fabricante_auto(fabricante_codigo)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_ta foreign key (tipo_de_auto) references FSOCIETY.BI_tipo_de_automovil(tipo_auto_codigo)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_tc foreign key (tipo_caja) references FSOCIETY.BI_tipo_de_caja(tipo_caja_codigo)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_tm foreign key (tipo_motor) references FSOCIETY.BI_tipo_de_motor(tipo_motor)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_tt foreign key (tipo_transmision) references FSOCIETY.BI_tipo_de_transmision(tipo_transmision_codigo)
		alter table FSOCIETY.BI_Venta_Automovil add constraint FK_BI_VA_potencia foreign key (potencia) references FSOCIETY.BI_potencia(codigo_potencia)
		go

		-- Fill
		insert into FSOCIETY.BI_Venta_Automovil
		select t.tiempo_id, c.cliente_id, factura_nro_factura, s.sucursal_id, a.auto_id, m.modelo_codigo, 
			fa.fabricante_codigo, ta.tipo_auto_codigo, tc.tipo_caja_codigo, tm.tipo_motor, tt.tipo_transmision_codigo,
			FSOCIETY.BI_asignar_potencia(m.modelo_potencia), va.venta_auto_precio_con_iva, va.venta_auto_precio_sin_iva
		from FSOCIETY.Venta_Auto va
			join FSOCIETY.BI_factura f on f.factura_nro_factura = va.venta_auto_factura_nro
			join FSOCIETY.BI_automovil a on a.auto_id = va.venta_auto_id
			join FSOCIETY.BI_Tiempo t on t.anio = f.factura_anio and t.mes = f.factura_mes
			join FSOCIETY.BI_cliente c on c.cliente_id = f.factura_cliente_id
			join FSOCIETY.BI_sucursal s on s.sucursal_id = f.factura_sucursal
			join FSOCIETY.BI_modelo m on a.auto_modelo_codigo = m.modelo_codigo
			join FSOCIETY.BI_fabricante_auto fa on fa.fabricante_codigo = a.auto_fabricante
			join FSOCIETY.BI_tipo_de_automovil ta on ta.tipo_auto_codigo = a.auto_tipo_de_automovil
			join FSOCIETY.BI_tipo_de_caja tc on tc.tipo_caja_codigo = a.auto_tipo_caja
			join FSOCIETY.BI_tipo_de_motor tm on tm.tipo_motor = a.auto_tipo_motor
			join FSOCIETY.BI_tipo_de_transmision tt on tt.tipo_transmision_codigo = a.auto_tipo_de_transmision
	go



	-- COMPRA DE AUTOS
	create table FSOCIETY.BI_Compra_Automovil(
		tiempo_id int,
		compra decimal(18,0),
		sucursal int,
		automovil int,
		modelo decimal(18,0),
		fabricante int,
		tipo_de_auto decimal(18,0),
		tipo_caja decimal(18,0),
		tipo_motor decimal(18,0),
		tipo_transmision decimal(18,0),
		potencia int,
		precio decimal(18,2)
	)
	go

		-- Constraints
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_tiempo foreign key (tiempo_id) references FSOCIETY.BI_Tiempo(tiempo_id)
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_factura foreign key (compra) references FSOCIETY.BI_compra(compra_nro)
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_sucursal foreign key (sucursal) references FSOCIETY.BI_sucursal(sucursal_id)
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_automovil foreign key (automovil) references FSOCIETY.BI_automovil(auto_id)
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_modelo foreign key (modelo) references FSOCIETY.BI_modelo(modelo_codigo)
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_fabricante foreign key (fabricante) references FSOCIETY.BI_fabricante_auto(fabricante_codigo)
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_ta foreign key (tipo_de_auto) references FSOCIETY.BI_tipo_de_automovil(tipo_auto_codigo)
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_tc foreign key (tipo_caja) references FSOCIETY.BI_tipo_de_caja(tipo_caja_codigo)
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_tm foreign key (tipo_motor) references FSOCIETY.BI_tipo_de_motor(tipo_motor)
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_tt foreign key (tipo_transmision) references FSOCIETY.BI_tipo_de_transmision(tipo_transmision_codigo)
		alter table FSOCIETY.BI_Compra_Automovil add constraint FK_BI_CA_potencia foreign key (potencia) references FSOCIETY.BI_potencia(codigo_potencia)
		go
		
		-- Fill
		insert into FSOCIETY.BI_Compra_Automovil
			select t.tiempo_id, c.compra_nro, s.sucursal_id, a.auto_id, m.modelo_codigo, 
				fa.fabricante_codigo, ta.tipo_auto_codigo, tc.tipo_caja_codigo, tm.tipo_motor, tt.tipo_transmision_codigo,
				FSOCIETY.BI_asignar_potencia(m.modelo_potencia), c.compra_precio_total
			from FSOCIETY.Compra_Auto ca
				join FSOCIETY.BI_compra c on c.compra_nro = ca.compra_auto_compra_nro
				join FSOCIETY.BI_automovil a on a.auto_id = ca.compra_auto_auto_id
				join FSOCIETY.BI_Tiempo t on t.anio = c.compra_anio and t.mes = c.compra_mes
				join FSOCIETY.BI_sucursal s on s.sucursal_id = c.compra_sucursal
				join FSOCIETY.BI_modelo m on a.auto_modelo_codigo = m.modelo_codigo
				join FSOCIETY.BI_fabricante_auto fa on fa.fabricante_codigo = a.auto_fabricante
				join FSOCIETY.BI_tipo_de_automovil ta on ta.tipo_auto_codigo = a.auto_tipo_de_automovil
				join FSOCIETY.BI_tipo_de_caja tc on tc.tipo_caja_codigo = a.auto_tipo_caja
				join FSOCIETY.BI_tipo_de_motor tm on tm.tipo_motor = a.auto_tipo_motor
				join FSOCIETY.BI_tipo_de_transmision tt on tt.tipo_transmision_codigo = a.auto_tipo_de_transmision
		go



/* CREACION DE VISTAS */

	-- **VISTAS PARA LAS AUTOPARTES**
		
		-- Ganancias x sucursal x mes
		create view FSOCIETY.BI_ganancias_sucursal_mes_autoparte as 
		select s.sucursal_id, t.mes, sum(va.precio_unitario * va.cantidad_vendida - ca.precio_unitario * ca.cantidad_comprada) as ganancia from FSOCIETY.BI_compra c
			join FSOCIETY.BI_Compra_Autoparte ca on c.compra_nro = ca.compra
			join FSOCIETY.BI_Venta_Autoparte va on va.autoparte = ca.autoparte
			join FSOCIETY.BI_factura f on f.factura_nro_factura = va.factura
			join FSOCIETY.BI_sucursal s on s.sucursal_id = f.factura_sucursal
			join FSOCIETY.BI_Tiempo t on va.tiempo_id = t.tiempo_id
		group by s.sucursal_id, t.mes
		go

		-- Precio Promedio de Autoparte vendida y comprada
		create view FSOCIETY.BI_precio_promedio_AP_vendida_comprada as
		select a.autoparte_codigo, cast(AVG(ca.precio_unitario) as decimal(18,2)) as precio_promedio_compra, cast(AVG(va.precio_unitario) as decimal(18,2)) as precio_promedio_venta from FSOCIETY.BI_autoparte a
			join FSOCIETY.BI_Compra_Autoparte ca on ca.autoparte = a.autoparte_codigo
			join FSOCIETY.BI_Venta_Autoparte va on va.autoparte = a.autoparte_codigo
		group by a.autoparte_codigo
	go
	
		-- Maxima cantidad de stock x año
		create view FSOCIETY.BI_maxima_cant_stock_x_anio as
		select ca.sucursal, t.anio, ca.autoparte, sum(ca.cantidad_comprada) as max_stock from FSOCIETY.BI_Compra_Autoparte ca
			join FSOCIETY.BI_Tiempo t on t.tiempo_id = ca.tiempo_id
		group by ca.sucursal, t.anio, ca.autoparte
	go




	-- **VISTAS PARA LOS AUTOS**
	
		-- Cantidad de autos vendidos y comprados x sucursal x mes
		--create view FSOCIETY.BI_cantidad_autos
		/*select s.sucursal_id, t.mes, count(ca.compra) as comprados, count(va.factura) as vendidos from FSOCIETY.BI_automovil a
			join FSOCIETY.BI_Compra_Automovil ca on ca.automovil = a.auto_id
			join FSOCIETY.BI_Venta_Automovil va on va.automovil = a.auto_id
			join FSOCIETY.BI_sucursal s on s.sucursal_id = ca.sucursal
			join FSOCIETY.BI_Tiempo t on t.tiempo_id = ca.tiempo_id
			group by s.sucursal_id, t.mes
			order by 1, 2
		go

		select s.sucursal_id, t.mes, count(a.auto_id), count(a2.auto_id) from FSOCIETY.BI_sucursal s
			join FSOCIETY.BI_factura f on f.factura_sucursal = s.sucursal_id
			join FSOCIETY.BI_Venta_Automovil va on va.factura = f.factura_nro_factura
			join FSOCIETY.BI_automovil a on a.auto_id = va.automovil
			join FSOCIETY.BI_Tiempo t on t.mes = f.factura_mes and t.anio = f.factura_anio
			join FSOCIETY.BI_compra c on c.compra_sucursal = s.sucursal_id
			join FSOCIETY.BI_Compra_Automovil ca on ca.compra = c.compra_nro
			join FSOCIETY.BI_automovil a2 on a2.auto_id = ca.automovil
		group by s.sucursal_id, t.mes
		*/
		-- Precio promedio de automoviles vendidos y comprados
		
		
		-- Ganancias x sucursal x mes
		create view FSOCIETY.BI_ganancias_sucursal_mes_automoviles as
		select s.sucursal_id, t.mes, sum(va.precio_con_iva - ca.precio) as ganancia from FSOCIETY.BI_automovil a
				join FSOCIETY.BI_Venta_Automovil va on va.automovil = a.auto_id
				left join FSOCIETY.BI_Compra_Automovil ca on ca.automovil = a.auto_id
				join FSOCIETY.BI_sucursal s on s.sucursal_id = va.sucursal
				join FSOCIETY.BI_Tiempo t on t.tiempo_id = ca.tiempo_id or t.tiempo_id = va.tiempo_id
			group by s.sucursal_id, t.mes
		go

		-- Promedio de tiempo en stock de cada modelo de automovil (en dias)
		create view FSOCIETY_BI_dias_promedio_en_stock_modelo as
			select  modelo_nombre, avg(DATEDIFF(dd, compra_fecha, venta_fecha)) as dias_promedio_stock from 
			(select m.modelo_nombre, c.compra_fecha as compra_fecha, isnull(f.factura_fecha, getdate()) venta_fecha from FSOCIETY.Compra_Auto ca
				left join FSOCIETY.Venta_Auto va on va.venta_auto_auto_id = ca.compra_auto_auto_id
				left join FSOCIETY.BI_Compra_Automovil ca1 on ca1.compra = ca.compra_auto_compra_nro
				left join FSOCIETY.BI_Venta_Automovil va1 on va1.factura = va.venta_auto_factura_nro
				join FSOCIETY.Compra c on c.compra_nro = ca.compra_auto_compra_nro
				join FSOCIETY.Factura f on f.factura_nro_factura = va1.factura
				join FSOCIETY.BI_automovil am on am.auto_id = ca.compra_auto_auto_id
				join FSOCIETY.Modelo m on am.auto_modelo_codigo = m.modelo_codigo) modelo_fechas
			group by modelo_nombre
		go
		
/*	
	DROPS

drop table FSOCIETY.BI_Venta_Autoparte
drop table FSOCIETY.BI_Compra_Autoparte
drop table FSOCIETY.BI_Venta_Automovil
drop table FSOCIETY.BI_Compra_Automovil
drop table FSOCIETY.BI_autoparte
drop table FSOCIETY.BI_factura
drop table FSOCIETY.BI_compra
drop table FSOCIETY.BI_cliente
drop table FSOCIETY.BI_rubro_autoparte
drop table FSOCIETY.BI_fabricante_autoparte
drop table FSOCIETY.BI_sucursal
drop table FSOCIETY.BI_tiempo

drop table FSOCIETY.BI_automovil
drop table FSOCIETY.BI_modelo
drop table FSOCIETY.BI_potencia
drop table FSOCIETY.BI_fabricante_auto
drop table FSOCIETY.BI_tipo_de_automovil
drop table FSOCIETY.BI_tipo_de_caja
drop table FSOCIETY.BI_tipo_de_motor
drop table FSOCIETY.BI_tipo_de_transmision

drop function FSOCIETY.BI_asignar_rango_etario
drop function FSOCIETY.BI_asignar_rango_de_potencia
drop function FSOCIETY.BI_asignar_potencia

drop view FSOCIETY.BI_ganancias_sucursal_mes_autoparte
drop view FSOCIETY.BI_precio_promedio_AP_vendida_comprada
drop view FSOCIETY.BI_maxima_cant_stock_x_anio

drop view FSOCIETY.BI_ganancias_sucursal_mes_automoviles
drop view FSOCIETY_BI_dias_promedio_en_stock_modelo
*/