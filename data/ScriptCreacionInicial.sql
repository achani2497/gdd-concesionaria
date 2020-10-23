use [GD2C2020]
go

/*Creacion del Schema*/
if(not exists(select * from sys.schemas where NAME = 'FSOCIETY'))
	begin
		exec('create schema[FSOCIETY]')
		print 'Creacion de Schema lista'
	end

create table FSOCIETY.Cliente (
	cliente_id						 int identity(1,1) primary key,
	cliente_nombre					 nvarchar (255),
	cliente_apellido				 nvarchar (255),
	cliente_direccion				 nvarchar (255),
	cliente_dni						 decimal (18,0),
	cliente_mail					 nvarchar (255),
	cliente_fecha_nac				 datetime2 (3),
	cliente_sexo					 char (1)	null
)
go

create table FSOCIETY.Tipo_Motor(
	tipo_motor_codigo 				decimal (18,0) primary key,
    tipo_motor_descripcion 			nvarchar (255)
)
go

create table FSOCIETY.Tipo_Caja(
	tipo_caja_codigo				 decimal (18,0) primary key,
	tipo_caja_descripcion			 nvarchar (255)
)
go

create table FSOCIETY.Tipo_Transmision(
	tipo_transmision_codigo			 decimal (18,0) primary key,
	tipo_transmision_descripccion	 nvarchar (255)
)
go

create table FSOCIETY.Sucursal(
	sucursal_id						 int identity(1,1) primary key,
	sucursal_direccion				 nvarchar (255),
	sucursal_mail					 nvarchar (255)			null,
	sucursal_telefono				 decimal (18,0)			null,
	sucursal_ciudad					 nvarchar (255)
)
go

create table FSOCIETY.Tipo_Auto(
	tipo_auto_codigo				 decimal (18,0) primary key,
	tipo_auto_desc					 nvarchar (255)
)
go

create table FSOCIETY.Auto_Parte(
	autoparte_codigo				 decimal (18,0) primary key,
	autoparte_descripcion			 nvarchar (255)			null,
	autoparte_rubro					 nvarchar (50)			null
)
go

--Tablas que tienen Foreign Keys
create table FSOCIETY.Modelo(
	modelo_id						 int identity (1,1) primary key,
	modelo_codigo					 decimal (18,0),
	modelo_nombre					 nvarchar (255),
	modelo_potencia					 decimal (18,0),
	modelo_tipo_caja				 decimal (18,0),
	modelo_tipo_transmision			 decimal (18,0),
    modelo_tipo_motor 				 decimal (18,0)
)
go

alter table FSOCIETY.Modelo add constraint FK_modelo_tipo_caja foreign key (modelo_tipo_caja) references FSOCIETY.Tipo_Caja(tipo_caja_codigo)
alter table FSOCIETY.Modelo add constraint FK_modelo_tipo_transmision foreign key (modelo_tipo_transmision) references FSOCIETY.Tipo_Transmision(tipo_transmision_codigo)
alter table FSOCIETY.Modelo add constraint FK_modelo_tipo_motor foreign key (modelo_tipo_motor) references FSOCIETY.Tipo_Motor(tipo_motor_codigo)

create table FSOCIETY.Automovil(
	auto_id							 int identity(1,1) primary key,
	auto_tipo_auto					 decimal (18,0),
	auto_modelo_id					 int,
	auto_nro_chasis					 nvarchar (50),
	auto_nro_motor					 nvarchar (50),
	auto_patente					 nvarchar (50),
	auto_fecha_alta					 datetime2 (3),
	auto_cant_kms					 decimal (18),
	auto_fabricante_nombre			 nvarchar (255),
)
go

alter table FSOCIETY.Automovil add constraint FK_auto_tipo_auto foreign key (auto_tipo_auto) references FSOCIETY.Tipo_Auto(tipo_auto_codigo)
alter table FSOCIETY.Automovil add constraint FK_auto_modelo foreign key (auto_modelo_id) references FSOCIETY.Modelo(modelo_id)
go

create table FSOCIETY.Factura(
	factura_id					     int identity (1,1) primary key,
	factura_nro_factura				 decimal (18),
	factura_sucursal_id				 int,
	factura_fecha					 datetime2 (3),
	factura_cliente_id				 int,
	factura_precio_facturado		 decimal (18,2),
	factura_cantidad_facturada		 decimal (18)
)
go

alter table FSOCIETY.Factura add constraint FK_factura_sucursal foreign key (factura_sucursal_id) references FSOCIETY.Sucursal(sucursal_id)
alter table FSOCIETY.Factura add constraint FK_factura_cliente foreign key (factura_cliente_id) references FSOCIETY.Cliente(cliente_id)
go

create table FSOCIETY.Venta_Auto(
	venta_auto_id					 int identity (1,1) primary key,
	venta_auto_auto_id				 int,
	venta_auto_venta_id				 int,
	venta_auto_precio_sin_iva		 decimal (18,2),
	venta_auto_precio_con_iva		 decimal (18,2)
)
go

alter table FSOCIETY.Venta_Auto add constraint FK_venta_auto_auto foreign key (venta_auto_auto_id) references FSOCIETY.Automovil(auto_id)
go

create table FSOCIETY.Venta_Autoparte(
	venta_autoparte_id				 int identity (1,1) primary key,
	venta_autoparte_venta_id		 int,
	venta_autoparte_autoparte_id	 decimal (18,0),
	venta_autoparte_cantidad		 int,
	venta_autoparte_precio_unitario  decimal (18,2),
	venta_autoparte_fecha			 datetime2 (3)
)
go

alter table FSOCIETY.Venta_Autoparte add constraint FK_venta_autoparte_autoparte foreign key (venta_autoparte_autoparte_id) references FSOCIETY.Auto_Parte(autoparte_codigo)
go

create table FSOCIETY.Compra(
	compra_id						 int identity (1,1) primary key,
	compra_sucursal_id				 int,
	compra_cliente_id				 int,
	compra_tipo_compra				 nchar (2),
	compra_fecha					 datetime2(3),
	compra_nro						 decimal (18)
)
go

alter table FSOCIETY.Compra add constraint FK_compra_sucursal foreign key (compra_sucursal_id) references FSOCIETY.Sucursal(sucursal_id)
alter table FSOCIETY.Compra add constraint FK_compra_cliente foreign key (compra_cliente_id) references FSOCIETY.Cliente(cliente_id)
go

create table FSOCIETY.Compra_Auto(
	compra_auto_id					 int identity (1,1) primary key,
	compra_auto_compra_id			 int,
	compra_auto_auto_id				 int,
	compra_auto_precio				 decimal (18,2),
	compra_auto_cantidad			 int
)
go

alter table FSOCIETY.Compra_Auto add constraint FK_compra_auto_compra foreign key (compra_auto_compra_id) references FSOCIETY.Compra(compra_id)
alter table FSOCIETY.Compra_Auto add constraint FK_compra_auto_auto foreign key (compra_auto_auto_id) references FSOCIETY.Automovil(auto_id)
go

create table FSOCIETY.Compra_Autoparte(
	compra_autoparte_id				 int identity (1,1) primary key,
	compra_autoparte_compra_id		 int,
	compra_autoparte_autoparte_id	 decimal (18,0),
	compra_autoparte_precio_unitario decimal (18,2),
	compra_autoparte_cantidad		 int
)
go

alter table FSOCIETY.Compra_Autoparte add constraint FK_compra_autoparte_compra foreign key (compra_autoparte_compra_id) references FSOCIETY.Compra(compra_id)
alter table FSOCIETY.Compra_Autoparte add constraint FK_compra_autoparte_autoparte foreign key (compra_autoparte_autoparte_id) references FSOCIETY.Auto_Parte(autoparte_codigo)
go

--Para la compra de autos voy a filtrar por la cantidad facturada, porque cuando vende autos está en NULL
--Tambien voy a tener que sacar el campo cantidad de la tabla Compra_Auto

/*Funciones*/
create function FSOCIETY.FX_precio_unitario_autoparte(@cantidad decimal(18,0), @precio_total decimal(18,2))
returns decimal(18,2)
as
begin
	return @precio_total / @cantidad
end
go

create function FSOCIETY.FX_tipo_compra(@cantidad decimal(18,0))
returns nchar(2)
as
begin
	if(@cantidad is not null)
		begin
			return 'ap'
		end

		return 'a'

end
go

/*Vistas*/
create view FSOCIETY.VW_datos_compras_table
as
	select distinct s.sucursal_id, c.cliente_id, FSOCIETY.FX_tipo_compra(m.compra_cant) as tipo_compra, m.compra_fecha, m.compra_nro, m.compra_cant, m.compra_precio
	from gd_esquema.Maestra m
	join FSOCIETY.Sucursal s on m.sucursal_ciudad = s.sucursal_ciudad and m.sucursal_direccion = s.sucursal_direccion
	join FSOCIETY.Cliente c on m.cliente_apellido = c.cliente_apellido and m.cliente_dni = c.cliente_dni and m.cliente_nombre = c.cliente_nombre
	where m.compra_nro is not null and m.factura_nro is null and m.COMPRA_CANT is not null
go

/*Procedures*/
create procedure FSOCIETY.PR_fill_cliente_table
as
begin
	
	insert into FSOCIETY.Cliente (cliente_nombre, cliente_apellido, cliente_direccion, cliente_dni, cliente_mail, cliente_fecha_nac)
	select distinct cliente_nombre, cliente_apellido, cliente_direccion, cliente_dni, cliente_mail, cliente_fecha_nac
	from gd_esquema.Maestra
	where cliente_dni is not null
	union
	select distinct fac_cliente_nombre, fac_cliente_apellido, fac_cliente_direccion, fac_cliente_dni, fac_cliente_mail, fac_cliente_fecha_nac
	from gd_esquema.Maestra
	where fac_cliente_apellido is not null

end
go

create procedure FSOCIETY.PR_fill_sucursal_table
as
begin
	insert into FSOCIETY.Sucursal (sucursal_direccion, sucursal_mail, sucursal_telefono, sucursal_ciudad)
	select distinct sucursal_direccion, sucursal_mail, sucursal_telefono, sucursal_ciudad from gd_esquema.Maestra where sucursal_direccion is not null
end
go

create procedure FSOCIETY.PR_fill_tipo_auto_table
as
begin
	insert into FSOCIETY.Tipo_Auto (tipo_auto_codigo, tipo_auto_desc)
	select distinct tipo_auto_codigo, tipo_auto_desc from gd_esquema.Maestra where tipo_auto_codigo is not null
end
go
 
create procedure FSOCIETY.PR_fill_tipo_caja_table
as
begin
	insert into FSOCIETY.Tipo_Caja (tipo_caja_codigo, tipo_caja_descripcion)
	select distinct tipo_caja_codigo, tipo_caja_desc from gd_esquema.Maestra where tipo_caja_codigo is not null
end
go

create procedure FSOCIETY.PR_fill_autoparte_table
as
begin
	insert into FSOCIETY.Auto_Parte (autoparte_codigo, autoparte_descripcion)
	select distinct auto_parte_codigo, auto_parte_descripcion from gd_esquema.Maestra where auto_parte_codigo is not null
end
go

create procedure FSOCIETY.PR_fill_tipo_transmision_table
as
begin
	insert into FSOCIETY.Tipo_Transmision (tipo_transmision_codigo, tipo_transmision_descripccion)
	select distinct tipo_transmision_codigo, tipo_transmision_desc from gd_esquema.Maestra where tipo_transmision_codigo is not null
end
go

create procedure FSOCIETY.PR_fill_tipo_motor_table
as
begin
	insert into FSOCIETY.Tipo_Motor (tipo_motor_codigo)
	select distinct tipo_motor_codigo from gd_esquema.Maestra where tipo_motor_codigo is not null order by tipo_motor_codigo

	update FSOCIETY.Tipo_Motor set tipo_motor_descripcion = 'gas' where tipo_motor_codigo = 1001
	update FSOCIETY.Tipo_Motor set tipo_motor_descripcion = 'electrico' where tipo_motor_codigo = 1002
	update FSOCIETY.Tipo_Motor set tipo_motor_descripcion = 'diesel' where tipo_motor_codigo = 1003
	update FSOCIETY.Tipo_Motor set tipo_motor_descripcion = 'gasolina' where tipo_motor_codigo = 1004
	update FSOCIETY.Tipo_Motor set tipo_motor_descripcion = 'hibrido' where tipo_motor_codigo = 1005
end
go

create procedure FSOCIETY.PR_fill_factura_table
as
begin
	insert into FSOCIETY.Factura (factura_nro_factura, factura_fecha, factura_precio_facturado, factura_cantidad_facturada, factura_sucursal_id, factura_cliente_id)
	select distinct factura_nro, factura_fecha, precio_facturado, cant_facturada, sucursal_id, cliente_id from gd_esquema.Maestra gdm
		join FSOCIETY.Sucursal s on s.sucursal_ciudad = gdm.fac_sucursal_ciudad and s.sucursal_telefono = gdm.fac_sucursal_telefono
		join FSOCIETY.Cliente c on c.cliente_apellido = gdm.fac_cliente_apellido and c.cliente_nombre = gdm.fac_cliente_nombre and c.cliente_dni = gdm.fac_cliente_dni
	where factura_nro is not null and cant_facturada is null
	union
	select distinct factura_nro, factura_fecha, sum(precio_facturado) precio_facturado, cant_facturada, sucursal_id, cliente_id from gd_esquema.Maestra gdm
		join FSOCIETY.Sucursal s on s.sucursal_ciudad = gdm.fac_sucursal_ciudad and s.sucursal_telefono = gdm.fac_sucursal_telefono
		join FSOCIETY.Cliente c on c.cliente_apellido = gdm.fac_cliente_apellido and c.cliente_nombre = gdm.fac_cliente_nombre and c.cliente_dni = gdm.fac_cliente_dni
	where factura_nro is not null and cant_facturada is not null
	group by factura_nro, factura_fecha, cant_facturada, cliente_id, sucursal_id
end
go

create procedure FSOCIETY.PR_fill_venta_autoparte_table
as
begin
	insert FSOCIETY.Venta_Autoparte (venta_autoparte_autoparte_id, venta_autoparte_cantidad, venta_autoparte_precio_unitario, venta_autoparte_fecha)
	select distinct ap.autoparte_codigo, m.cant_facturada, FSOCIETY.FX_precio_unitario_autoparte(m.cant_facturada, m.precio_facturado) as precio_unitario, m.factura_fecha 
	from gd_esquema.Maestra m
	join FSOCIETY.Auto_Parte ap on ap.autoparte_codigo = m.AUTO_PARTE_CODIGO
	where m.cant_facturada is not null and m.compra_nro is null
	group by ap.autoparte_codigo, m.cant_facturada, m.precio_facturado, m.factura_fecha
end
go

create procedure FSOCIETY.PR_fill_compra_table
as
begin

	insert into FSOCIETY.Compra(compra_sucursal_id, compra_cliente_id, compra_tipo_compra, compra_fecha, compra_nro)
	select sucursal_id, cliente_id, tipo_compra, compra_fecha, compra_nro from FSOCIETY.VW_datos_compras_table

	insert into FSOCIETY.Compra(compra_sucursal_id, compra_cliente_id, compra_tipo_compra, compra_fecha, compra_nro)
	select s.sucursal_id, c.cliente_id, FSOCIETY.FX_tipo_compra(m.compra_cant) as tipo_compra, m.compra_fecha, m.compra_nro 
	from gd_esquema.Maestra m
	join FSOCIETY.Sucursal s on m.sucursal_ciudad = s.sucursal_ciudad and m.sucursal_direccion = s.sucursal_direccion
	join FSOCIETY.Cliente c on m.cliente_apellido = c.cliente_apellido and m.cliente_dni = c.cliente_dni and m.cliente_nombre = c.cliente_nombre
	where m.compra_nro is not null and m.factura_nro is null and m.COMPRA_CANT is null

end
go

/*
exec FSOCIETY.PR_fill_cliente_table
exec FSOCIETY.PR_fill_sucursal_table
exec FSOCIETY.PR_fill_tipo_auto_table
exec FSOCIETY.PR_fill_tipo_caja_table
exec FSOCIETY.PR_fill_autoparte_table
exec FSOCIETY.PR_fill_tipo_transmision_table
exec FSOCIETY.PR_fill_tipo_motor_table
exec FSOCIETY.PR_fill_factura_table
exec FSOCIETY.PR_fill_venta_autoparte_table
*/
/*
select * from FSOCIETY.Cliente
select * from FSOCIETY.Sucursal
select * from FSOCIETY.Tipo_Auto
select * from FSOCIETY.Tipo_Caja
select * from FSOCIETY.Auto_Parte
select * from FSOCIETY.Tipo_Transmision
select * from FSOCIETY.Tipo_Motor
select * from FSOCIETY.Factura
select * from FSOCIETY.Auto_Parte
*/
/*
drop table FSOCIETY.Compra_Auto;
drop table FSOCIETY.Compra_Autoparte;
drop table FSOCIETY.Compra;
drop table FSOCIETY.Venta_Auto;
drop table FSOCIETY.Venta_Autoparte;
drop table FSOCIETY.Automovil;
drop table FSOCIETY.Auto_Parte;
drop table FSOCIETY.Factura;
drop table FSOCIETY.Tipo_Auto;
drop table FSOCIETY.Modelo;
drop table FSOCIETY.Tipo_Caja;
drop table FSOCIETY.Tipo_Transmision;
drop table FSOCIETY.Tipo_Motor;
drop table FSOCIETY.Cliente;
drop table FSOCIETY.Sucursal;

drop function FSOCIETY.FX_precio_unitario_autoparte
drop function FSOCIETY.FX_tipo_compra

drop procedure FSOCIETY.PR_fill_cliente_table
drop procedure FSOCIETY.PR_fill_sucursal_table
drop procedure FSOCIETY.PR_fill_tipo_auto_table
drop procedure FSOCIETY.PR_fill_tipo_caja_table
drop procedure FSOCIETY.PR_fill_autoparte_table
drop procedure FSOCIETY.PR_fill_tipo_transmision_table
drop procedure FSOCIETY.PR_fill_tipo_motor_table
drop procedure FSOCIETY.PR_fill_factura_table
drop procedure FSOCIETY.PR_fill_venta_autoparte_table
drop procedure FSOCIETY.PR_fill_compra_table
go
*/