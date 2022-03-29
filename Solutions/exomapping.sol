contract Shop{
   mapping(string => Item) public shop;
   struct Item {
       uint price;
       uint units;
   }
   function createItem(string memory _name, uint _price) external {
       /*method1.*/   
       shop[_name] = Item(_price, 1);      
       /* method2.
       shop[_name].price = _price;
       shop[_name].units = 1;
       */  
       /*method3. 
       shop[_name] = Item({price :_price, units: 1});
       */
   }
      function setItem(string memory _name, uint _price, uint _units) external {
       shop[_name].price = _price;
       shop[_name].units = _units;
   }

   function getItem(string memory _name) public view returns(uint, uint) {
       return (shop[_name].price, shop[_name].units);
   }
}