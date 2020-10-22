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
	modelo_tipo_transmision			 decimal (18,0)
)
go

alter table FSOCIETY.Modelo add constraint FK_modelo_tipo_caja foreign key (modelo_tipo_caja) references FSOCIETY.Tipo_Caja(tipo_caja_codigo)
alter table FSOCIETY.Modelo add constraint FK_modelo_tipo_transmision foreign key (modelo_tipo_transmision) references FSOCIETY.Tipo_Transmision(tipo_transmision_codigo)

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
	auto_tipo_motor_codigo			 decimal (18)
)
go

alter table FSOCIETY.Automovil add constraint FK_auto_tipo_auto foreign key (auto_tipo_auto) references FSOCIETY.Tipo_Auto(tipo_auto_codigo)
alter table FSOCIETY.Automovil add constraint FK_auto_modelo foreign key (auto_modelo_id) references FSOCIETY.Modelo(modelo_id)
go

create table FSOCIETY.Factura(
	factura_id					     int identity (1,1) primary key,
	factura_nro_factura				 decimal (18) unique,
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

create table FSOCIETY.Venta(
	venta_id						 int identity (1,1) primary key,
	venta_factura_id				 int,
	venta_tipo_venta				 nchar(2)
)
go

alter table FSOCIETY.Venta add constraint FK_venta_factura foreign key (venta_factura_id) references FSOCIETY.Factura(factura_id)
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
alter table FSOCIETY.Venta_Auto add constraint FK_venta_auto_venta foreign key (venta_auto_venta_id) references FSOCIETY.Venta(venta_id)
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

alter table FSOCIETY.Venta_Autoparte add constraint FK_venta_autoparte_venta foreign key (venta_autoparte_venta_id) references FSOCIETY.Venta(venta_id)
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

--TODO: Borra esto
/*create view FSOCIETY.vw_datos_modelos as
	select distinct modelo_codigo, modelo_nombre, modelo_potencia from gd_esquema.Maestra
go*/
--Para la compra de autos voy a filtrar por la cantidad facturada, porque cuando vende autos está en NULL
--Tambien voy a tener que sacar el campo cantidad de la tabla Compra_Auto
/*select * from gd_esquema.Maestra
go*/

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

/*select * from FSOCIETY.Cliente
select * from FSOCIETY.Sucursal
select * from FSOCIETY.Tipo_Auto
select * from FSOCIETY.Tipo_Caja
select * from FSOCIETY.Auto_Parte
select * from FSOCIETY.Tipo_Transmision
*/
/*
drop table FSOCIETY.Compra_Auto;
drop table FSOCIETY.Compra_Autoparte;
drop table FSOCIETY.Compra;
drop table FSOCIETY.Venta_Auto;
drop table FSOCIETY.Venta_Autoparte;
drop table FSOCIETY.Venta;
drop table FSOCIETY.Automovil;
drop table FSOCIETY.Auto_Parte;
drop table FSOCIETY.Factura;
drop table FSOCIETY.Tipo_Auto;
drop table FSOCIETY.Modelo;
drop table FSOCIETY.Tipo_Caja;
drop table FSOCIETY.Tipo_Transmision;
drop table FSOCIETY.Cliente;
drop table FSOCIETY.Sucursal;

drop procedure FSOCIETY.PR_fill_autoparte_table
drop procedure FSOCIETY.PR_fill_cliente_table
drop procedure FSOCIETY.PR_fill_sucursal_table
drop procedure FSOCIETY.PR_fill_tipo_auto_table
drop procedure FSOCIETY.PR_fill_tipo_caja_table
drop procedure FSOCIETY.PR_fill_tipo_transmision_table

go
*/