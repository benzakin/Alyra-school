contract Magasin {
   struct Item {
       string name;
       uint price;
       uint units; 
   }
   Item[] public items;
   function addItem(string memory _name, uint _price, uint _units) public {
       Item memory item = Item(_name, _price, _units);
       items.push(item);  
   }
   function deleteItem() public {
       items.pop();
   }
function totalItem() public view returns(uint){
       return items.length;
   }
   function getItem(uint _id) public view returns(string memory) {
       return items[_id].name;
   }
   function setItem(uint _id, uint _price, string memory _name, uint _units) public  returns(bool) {
       items[_id].price = _price;
       items[_id].name = _name;
       items[_id].units = _units;
       //
       Item memory item = Item(_name, _price, _units);
       items[_id] = item;
       //
       items[_id] = Item(_name,_price, _units);
       return true;
   }
}