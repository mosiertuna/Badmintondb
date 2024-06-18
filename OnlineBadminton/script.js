const url = 'http://localhost:8081/';
const prevBtn = document.getElementById("prev");
const nextBtn = document.getElementById("next");
const curr_page = document.getElementById("curr_page");
var page = 1;
const per_page = 12;
var max_page = null;
let param = "";
var dat = null;
var customer = null;
var order = null;
getItemList()
document.getElementById("cart").addEventListener('click', () => {
    window.location.href = url + "ShoppingCart/cart.html";
})
prevBtn.addEventListener('click', () =>{
    page--;

    update_page();
});
nextBtn.addEventListener('click', ()=>{
    page++;

    update_page();
})
checkCookie();

function debounce(func, delay) {
    let timeout;
    return function() {
        const context = this;
        const args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(context, args), delay);
    };
}

const debouncedSearchItemList = debounce(getItemList, 300);

// Add event listeners for form elements to trigger search dynamically
document.getElementById('search_query').addEventListener('input', debouncedSearchItemList);
document.getElementById('price_range').addEventListener('change', debouncedSearchItemList);
document.getElementById('product_type').addEventListener('change', debouncedSearchItemList);
document.getElementById('brand_name').addEventListener('change', debouncedSearchItemList);



function update_page(){
    curr_page.textContent = `Page ${page} of ${max_page}`;
    if(page == max_page){
        nextBtn.classList.remove("display_buttons");
        nextBtn.classList.add("hide_buttons");
        if(max_page == 2){
        prevBtn.classList.add("display_buttons");
        prevBtn.classList.remove("hide_buttons");
        }
        else if (max_page ==1 ){
        prevBtn.classList.remove("display_buttons");
        prevBtn.classList.add("hide_buttons");
        }
    }
    else if(page == 1&&max_page!=1){
        prevBtn.classList.remove("display_buttons");
        prevBtn.classList.add("hide_buttons");
        nextBtn.classList.add("display_buttons");
        nextBtn.classList.remove("hide_buttons");
    }
    else{
        nextBtn.classList.add("display_buttons");
        nextBtn.classList.remove("hide_buttons");
        prevBtn.classList.add("display_buttons");
        prevBtn.classList.remove("hide_buttons");
    }
    const items_list = document.getElementById("items_list");
    items_list.innerHTML="";

    for (let i = per_page * page - per_page; i < per_page * page && i < dat.length; ++i) {
        // Create the HTML for the item
        let itemHTML = `
        <div class="items" id="prd${dat[i].product_id}">
            <div class="prd_id">ID: ${dat[i].product_id}</div>
            <br>Name: ${dat[i].product_name}</br>
            <br>Unit price: ${dat[i].unit_price}</br>
            <br>Description: ${dat[i].description}</br>
            <div class="item_quantity">
                <h3>Quantity</h3>
                <input class="qt_form" id="qt${dat[i].product_id}" type="number" min="0" max="999" value="0" />
                <button class="update_button" id="u${dat[i].product_id}">Order</button>
            </div>
        </div>`;
        
        // Append the item HTML to the items list
        items_list.innerHTML += itemHTML;
    }
    
    // After appending all items, attach event listeners to the buttons
    for (let i = per_page * page - per_page; i < per_page * page && i < dat.length; ++i) {
        $(`#u${dat[i].product_id}`).on("click", () => {
            let q = $(`#qt${dat[i].product_id}`).val();
            if (q > 0) alert(`Added ${q} unit(s) of ${dat[i].product_name} to cart!`);
            updateCart(q, dat[i].product_id);
        });
    }
    
    
   
   

}



async function getItemList(){ 
    const form = document.getElementById('filter_form');
        
    if (!(form instanceof HTMLFormElement)) {
        console.error('filter_form is not an HTMLFormElement');
        return;
    }
    
    const formData = new FormData(form);
    const queryString = new URLSearchParams(formData).toString();
    const query_url = `http://localhost:8081/getItemList?${queryString}`;
    console.log(queryString)
    const res = await fetch(query_url ,
        {
            method: 'GET',
            
            })
    const data = await res.json();
    dat = data.info;
    max_page = Math.ceil(data.maxpage/per_page);
    console.log(dat);
    page = 1;
    update_page();
        }

async function updateCart(qtt, id) {
            const res = await fetch(`${url}updateCart?customer_id=${customer}&order_id=${order}&product_id=${id}&quantity=${qtt}`, {
                method: 'GET'
            });
            
            const data = await res.json();
            const cart_dat = data.info;
            console.log(cart_dat);
            if(cart_dat.length > 0 ){
                customer = cart_dat[0].new_customer_id;
                setCookie("user",customer,30);
         
                order = cart_dat[0].new_order_id;
                setCookie("order",order,30);    
            
            }
            console.log(customer);
            console.log(order)
        }
        
        

//COOKIES FUNCTIONS
function setCookie(cname,cvalue,exdays) {
    const d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    let expires = "expires=" + d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
  }
  
  function getCookie(cname) {
    let name = cname + "=";
    let decodedCookie = decodeURIComponent(document.cookie);
    let ca = decodedCookie.split(';');
    for(let i = 0; i < ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
  }
  
  function checkCookie() {
    let user = getCookie("user");
    let ord = getCookie("order")
    if (user != "") {
      customer = user
    } 
    if (ord != ""){
      order = ord
    }
  }


