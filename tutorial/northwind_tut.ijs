
jdadmin'northwind'
jd'reads Description from Categories'
jd'reads Address,City from Suppliers where Country="UK"'
jd'reads ProductName,Categories.CategoryName from Products,Products.Categories where Categories.CategoryName="Beverages"'
jd'reads Products.ProductName,Suppliers.City from Products,Products.Suppliers where Suppliers.CompanyName="Exotic Liquids"'
jd'reads ProductName,UnitPrice from Products where UnitPrice<10'
jd'reads Suppliers.Country,Categories.CategoryName from Products,Products.Categories,Products.Suppliers where Suppliers.Country="UK"'
jd'reads CustomerID from Customers where Country="UK"'
jd'reads Country,HireDate from Employees where Country<>"UK" and HireDate>19930000'
jd'reads from Shippers'
jd'reads Customers.Country,Employees.Country,Shippers.ShipperID from Orders,Orders.Customers,Orders.Employees,Orders.Shippers where Customers.Country="UK" and Employees.Country="UK" and Shippers.ShipperID=1'
jd'reads Customers.Country,OrderDetails.Quantity from OrderDetails,OrderDetails.Orders.Customers where Customers.Country="UK" and OrderDetails.Quantity>60'
jd'reads count:count Country by Country from Suppliers'
jd'reads min:min UnitsInStock,max:max UnitsInStock by Suppliers.Country from Products,Products.Suppliers'
