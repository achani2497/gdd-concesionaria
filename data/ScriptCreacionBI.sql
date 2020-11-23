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
	--Sucursal
	create table FSOCIETY.BI_sucursal(
		sucursal_id int primary key,
		sucursal_direccion nvarchar(255),
		sucursal_mail nvarchar(255),
		sucursal_telefono decimal(18,0),
		sucursal_ciudad nvarchar(255)
	)
	--Modelo
	create table FSOCIETY.BI_modelo(
		modelo_codigo decimal(18,0),
		modelo_nombre nvarchar(255),
		modelo_potencia decimal(18,0)
	)
	--Fabricante
	create table FSOCIETY.BI_fabricante(					--TODO: Falta hacer la migracion en Script_Inicial para poder levantar los datos del fabricante
		fabricante_codigo int primary key,
		fabricante_nombre nvarchar(255)
	)
	select * from gd_esquema.Maestra where fabricante_nombre != ''
	select * from FSOCIETY.

--BI_Compra_Automoviles
--BI_Venta_Automoviles
--BI_Compra_Autopartes
--BI_Venta_Autopartes
create table FSOCIETY.BI_Compra_Automoviles(
	--TODO:
)
go
--dimensiones de esta tabla de hechos:
/*
	Tiempo (año y mes) -> Lo saco de las compras de autos
	Sucursal
	Modelo
	Fabricante
	Tipo de Automovil
	Tipo caja de cambios
	Tipo motor
	Tipo transmision
	Potencia
*/

create table FSOCIETY.BI_Venta_Automoviles(
	--TODO:
)
go
--dimensiones
/*
-- Tiempo (año y mes) -> Lo saco de las compras de autos
-- Sucursal
-- Modelo
-- Fabricante
-- Tipo de Automovil
-- Tipo caja de cambios
-- Tipo motor
-- Tipo transmision
-- Potencia	
*/
create table FSOCIETY.BI_Compra_Autopartes(
	--TODO:
)
go
--dimensiones
/*
	Tiempo
	Sucursal
	Autoparte
	Rubro Autoparte
	Fabricante
*/
create table FSOCIETY.BI_Venta_Autopartes(
	--TODO:
)
go
/*
	Tiempo
	Sucursal
	Autoparte
	Rubro Autoparte
	Fabricante
*/