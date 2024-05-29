const url = 'http://localhost:8081/';
const prevBtn = document.getElementById("prev");
const nextBtn = document.getElementById("next");
const curr_page = document.getElementById("curr_page");
var page = 1;
const per_page = 12;
var max_page = null;
let param = "";
var dat = null;
updateURL("page",page);
getData()
prevBtn.addEventListener('click', () =>{
    page--;
    updateURL("page",page);
    update_page();
});
nextBtn.addEventListener('click', ()=>{
    page++;
    updateURL("page",page);
    update_page();
})

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

    document.getElementById("items_list").innerHTML="";

    for(i = per_page*page - per_page; i<per_page*page&&i<dat.length; ++i){
        document.getElementById("items_list").innerHTML += `<div class="items">ID: ${dat[i].product_id}
        <br>Name: ${dat[i].name}</br>
        <br>Unit price: ${dat[i].unit_price}</br>
        <br>Description: ${dat[i].description}</br>
        <div class="item_quantity">
        <h3>Quantity</h3>
        <input type="number" id="quantity" min="0" max="999" value = 0 />
        <button>Order</button>
        </div>
        </div>`;
    }
   
   

}

function updateURL(key, value){
    const searchParams = new URLSearchParams(window.location.search);
    searchParams.set(key,value);
    const newRelativePathQuery = window.location.pathname + "?" + searchParams.toString();
    history.pushState(null,"",newRelativePathQuery);
    param = newRelativePathQuery;
}


async function getData(){
    const res = await fetch(url + "info" + param,
        {
            method: 'GET',
            
            })
    const data = await res.json();
    dat = data.info;
    max_page = Math.ceil(data.maxpage/per_page);
    console.log(dat);
    update_page();
        }


