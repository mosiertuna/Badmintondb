const url = 'http://localhost:8081/cart.html/';
var dat = null;
document.getElementById("home").addEventListener('click', () => {
    window.location.href = 'http://localhost:8081/';
})
getShoppingList();
update_page();
function update_page(){
    if(dat !=null){
    for(i = 0; i<dat.length; ++i){
            document.getElementById("items_list").innerHTML += `<div class="items">ID: ${dat[i].product_id}
            <br>Name: ${dat[i].name}</br>
            <br>Unit price: ${dat[i].unit_price}</br>
            <br>Description: ${dat[i].description}</br>
            <div class="item_quantity">
            <h3>Quantity</h3>
            <input type="number" id="${dat[i].product_id} + ${dat[i].order_id}" min="0" max="999" value = 0 />
            <button>Update</button>
            </div>
            </div>`;
        }
    }
}
async function getShoppingList(){
    const res = await fetch(url + "info",
        {
            method: 'GET',
            
            })
    const data = await res.json();
    dat = data.info;
    console.log(dat);
    update_page();
        }