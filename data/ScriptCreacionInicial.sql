use [GD2C2020]
create table Cliente (
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

create table Tipo_Caja(
	tipo_caja_id					 int identity(1,1) primary key,
	tipo_caja_codigo				 decimal (18,0),
	tipo_caja_descripcion			 nvarchar (255)
)
go

create table Tipo_Transmision(
	tipo_transmision_id				 int identity(1,1) primary key,
	tipo_transmision_codigo			 decimal (18,0),
	tipo_transmision_descripccion	 nvarchar (255)
)
go

create table Sucursal(
	sucursal_id						 int identity(1,1) primary key,
	sucursal_direccion				 nvarchar (255),
	sucursal_mail					 nvarchar (255)			null,
	sucursal_telefono				 decimal (18,0)			null,
	sucursal_ciudad					 nvarchar (255)
)
go

create table Tipo_Auto(
	tipo_auto_id					 int identity (1,1) primary key,
	tipo_auto_codigo				 decimal (18),
	tipo_auto_desc					 nvarchar (255)
)
go

create table Auto_Parte(
	autoparte_id					 int identity (1,1) primary key,
	autoparte_codigo				 decimal (18),
	autoparte_descripcion			 nvarchar (255)			null,
	autoparte_rubro					 nvarchar (50)			null
)
go

--Tablas que tienen Foreign Keys
create table Modelo(
	modelo_id						 int identity (1,1) primary key,
	modelo_codigo					 decimal (18),
	modelo_nombre					 nvarchar (255),
	modelo_potencia					 decimal (18),
	modelo_tipo_caja				 int,
	modelo_tipo_transmision			 int
)
go

alter table Modelo add constraint FK_modelo_tipo_caja foreign key (modelo_tipo_caja) references Tipo_Caja(tipo_caja_id)
alter table Modelo add constraint FK_modelo_tipo_transmision foreign key (modelo_tipo_transmision) references Tipo_Transmision(tipo_transmision_id)

create table Auto(
	auto_id							 int identity(1,1) primary key,
	auto_tipo_auto					 int foreign key references Tipo_Auto(tipo_auto_id),
	auto_modelo_id					 int foreign key references Modelo(modelo_id),
	auto_nro_chasis					 nvarchar (50),
	auto_nro_motor					 nvarchar (50),
	auto_patente					 nvarchar (50),
	auto_fecha_alta					 datetime2 (3),
	auto_cant_kms					 decimal (18),
	auto_fabricante_nombre			 nvarchar (255),
	auto_tipo_motor_codigo			 decimal (18)
)
go

alter table Auto add constraint FK_auto_tipo_auto foreign key (auto_tipo_auto) references Tipo_Auto(tipo_auto_id)
alter table Auto add constraint FK_auto_modelo foreign key (auto_modelo_id) references Modelo(modelo_id)

create table Factura(
	factura_id					     int identity (1,1) primary key,
	factura_nro_factura				 decimal (18) unique,
	factura_sucursal_id				 int foreign key references Sucursal(sucursal_id),
	factura_fecha					 datetime2 (3),
	factura_cliente_id				 int foreign key references Cliente(cliente_id),
	factura_precio_facturado		 decimal (18,2),
	factura_cantidad_facturada		 decimal (18)
)
go

alter table Factura add constraint FK_factura_sucursal foreign key (factura_sucursal_id) references Sucursal(sucursal_id)
alter table Factura add constraint FK_factura_cliente foreign key (factura_cliente_id) references Cliente(cliente_id)
go

create table Venta(
	venta_id						 int identity (1,1) primary key,
	venta_factura_id				 int foreign key references Factura(factura_id),
	venta_tipo_venta				 nchar(2)
)
go

alter table Venta add constraint FK_venta_factura foreign key (venta_factura_id) references Factura(factura_id)
go

create table Venta_Auto(
	venta_auto_id					 int identity (1,1) primary key,
	venta_auto_auto_id				 int foreign key references Auto(auto_id),
	venta_auto_venta_id				 int foreign key references Venta(venta_id),
	venta_auto_precio_sin_iva		 decimal (18,2),
	venta_auto_precio_con_iva		 decimal (18,2)
)
go

alter table Venta_Auto add constraint FK_venta_auto_auto foreign key (venta_auto_auto_id) references Auto(auto_id)
alter table Venta_Auto add constraint FK_venta_auto_venta foreign key (venta_auto_venta_id) references Venta(venta_id)
go

create table Venta_Autoparte(
	venta_autoparte_id				 int identity (1,1) primary key,
	venta_autoparte_venta_id		 int foreign key references Venta(venta_id),
	venta_autoparte_autoparte_id	 int foreign key references Auto_Parte(autoparte_id),
	venta_autoparte_cantidad		 int,
	venta_autoparte_precio_unitario  decimal (18,2),
	venta_autoparte_fecha			 datetime2 (3)
)
go

alter table Venta_Autoparte add constraint FK_venta_autoparte_venta foreign key (venta_autoparte_venta_id) references Venta(venta_id)
alter table Venta_Autoparte add constraint FK_venta_autoparte_autoparte foreign key (venta_autoparte_autoparte_id) references Auto_Parte(autoparte_id)
go

create table Compra(
	compra_id						 int identity (1,1) primary key,
	compra_sucursal_id				 int,
	compra_cliente_id				 int,
	compra_tipo_compra				 nchar (2),
	compra_fecha					 datetime2(3),
	compra_nro						 decimal (18)
)
go

alter table Compra add constraint FK_compra_sucursal foreign key (compra_sucursal_id) references Sucursal(sucursal_id)
alter table Compra add constraint FK_compra_cliente foreign key (compra_cliente_id) references Cliente(cliente_id)
go

create table Compra_Auto(
	compra_auto_id					 int identity (1,1) primary key,
	compra_auto_compra_id			 int,
	compra_auto_auto_id				 int,
	compra_auto_precio				 decimal (18,2),
	compra_auto_cantidad			 int
)
go

alter table Compra_Auto add constraint FK_compra_auto_compra foreign key (compra_auto_compra_id) references Compra(compra_id)
alter table Compra_Auto add constraint FK_compra_auto_auto foreign key (compra_auto_auto_id) references Auto(auto_id)
go

create table Compra_Autoparte(
	compra_autoparte_id				 int identity (1,1) primary key,
	compra_autoparte_compra_id		 int,
	compra_autoparte_autoparte_id	 int,
	compra_autoparte_precio_unitario decimal (18,2),
	compra_autoparte_cantidad		 int
)
go

alter table Compra_Autoparte add constraint FK_compra_autoparte_compra foreign key (compra_autoparte_compra_id) references Compra(compra_id)
alter table Compra_Autoparte add constraint FK_compra_autoparte_autoparte foreign key (compra_autoparte_autoparte_id) references Auto_Parte(autoparte_id)
go

/*Vistas*/
create view vw_datos_clientes as 
	select distinct cliente_nombre, cliente_apellido, cliente_direccion, cliente_dni, cliente_mail, cliente_fecha_nac from gd_esquema.Maestra where CLIENTE_DNI is not null
go

create view vw_datos_sucursales as
	select distinct sucursal_direccion, sucursal_mail, sucursal_telefono, sucursal_ciudad from gd_esquema.Maestra where sucursal_direccion is not null
go

create view vw_datos_tipos_auto as
	select distinct tipo_auto_codigo, tipo_auto_desc from gd_esquema.Maestra where tipo_auto_codigo is not null
go

create view vw_datos_tipos_cajas as
	select distinct tipo_caja_codigo, tipo_caja_desc from gd_esquema.Maestra where tipo_caja_codigo is not null
go

create view vw_datos_autopartes as
	select distinct auto_parte_codigo, auto_parte_descripcion from gd_esquema.Maestra where auto_parte_codigo is not null
go

create view vw_datos_tipos_transmision as
	select distinct tipo_transmision_codigo, tipo_transmision_desc from gd_esquema.Maestra where tipo_transmision_codigo is not null
go

create view vw_datos_modelos as
	select distinct modelo_codigo, modelo_nombre, modelo_potencia from gd_esquema.Maestra
go
--Para la compra de autos voy a filtrar por la cantidad facturada, porque cuando vende autos está en NULL
--Tambien voy a tener que sacar el campo cantidad de la tabla Compra_Auto
select * from gd_esquema.Maestra
go

/*Procedures*/
create procedure PR_fill_cliente_table
as
begin
	
	insert into Cliente (cliente_nombre, cliente_apellido, cliente_direccion, cliente_dni, cliente_mail, cliente_fecha_nac)
	select * from vw_datos_clientes

end
go

create procedure PR_fill_sucursal_table
as
begin
	insert into Sucursal (sucursal_direccion, sucursal_mail, sucursal_telefono, sucursal_ciudad)
	select * from vw_datos_sucursales
end
go

create procedure PR_fill_tipo_auto_table
as
begin
	insert into Tipo_Auto (tipo_auto_codigo, tipo_auto_desc)
	select * from vw_datos_tipos_auto order by tipo_auto_codigo
end
go
 
create procedure PR_fill_tipo_caja_table
as
begin
	insert into Tipo_Caja(tipo_caja_codigo, tipo_caja_descripcion)
	select * from vw_datos_tipos_cajas order by tipo_caja_codigo
end
go

create procedure PR_fill_autoparte_table
as
begin
	insert into Auto_Parte(autoparte_codigo, autoparte_descripcion)
	select * from vw_datos_autopartes
end
go

create procedure PR_fill_tipo_transmision_table
as
begin
	insert into Tipo_Transmision(tipo_transmision_codigo, tipo_transmision_descripccion)
	select * from vw_datos_tipos_transmision order by tipo_transmision_codigo
end
go

select * from Cliente
select * from Sucursal
select * from Tipo_Auto --TODO: Revisar si saco o no el id de esta tabla
select * from Tipo_Caja --TODO: Revisar si saco o no el id de esta tabla
select * from Auto_Parte --TODO: Revisar si saco o no el id de esta tabla
select * from Tipo_Transmision --TODO: Revisar si saco o no el id de esta tabla

/*
drop table Compra_Auto;
drop table Compra_Autoparte;
drop table Compra;
drop table Venta_Auto;
drop table Venta_Autoparte;
drop table Venta;
drop table Auto;
drop table Auto_Parte;
drop table Factura;
drop table Tipo_Auto;
drop table Modelo;
drop table Tipo_Caja;
drop table Tipo_Transmision;
drop table Cliente;
drop table Sucursal;

go
*/