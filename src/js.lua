JS = {
    DisableArizonaHUD = [[
        const hud = document.querySelector(".player-info");
        if (hud)
            hud.style.display = "none";
        console.log("[MouHUD] DisableArizonaHUD:", hud)
    ]],
    EnableArizonaHUD = [[
        const hud = document.querySelector(".player-info");
        if (hud)
            hud.style.display = "block";
        console.log("[MouHUD] DisableArizonaHUD:", hud)
    ]],
    CheckGreenZone = [[
        const greenZoneElement = document.querySelector(".player-info__green-zone");
        window.cef.SendMessage(`mouhud:setIsGreenZone;${greenZoneElement ? 1 : 0}`, null);
        console.log("[MouHUD] CheckGreenZone:", greenZoneElement)
    ]],
    UpdateServerNumber = [[
        const serverNumber = document.querySelector(".player-info__server-number)
        if (serverNumber)
            window.cef.SendMessage(`mouhud:setServerNumber;${serverNumber ? serverNumber.textContent : 0}`, null);
        console.log("[MouHUD] UpdateServerNumber:", serverNumber ? "OK" : "None")
    ]],
    SetupInfotHooks = [[
        console.log("[MouHUD] Starting loop...");

        function UpdateMouHUD() {
            console.log("[MouHUD] Loop");
            
            // Green zone
            const greenZoneElement = document.querySelector(".player-info__green-zone");
            window.cef.SendMessage(`mouhud:setIsGreenZone;${greenZoneElement ? 1 : 0}`, null);

            // Server Number
            //const serverNumber = document.querySelector(".player-info__server-number)
            //window.cef.SendMessage(`mouhud:setServer;${serverNumber ? serverNumber.textContent : "0"}`, null);

            // Vehicle
            const vehicleInfo = [
                { event: "setSpeed", class: ".speedometer-simplified__speed-indicator-value" },
                { event: "setFuel", class: ".speedometer-simplified__fuel-indicator .circle-indicator__count" },
                { event: "setMileage", class: ".speedometer-simplified__mileage-value" },
                { event: "setServer", class: ".player-info__server-number", fallbackValue: "0" }
            ];
            
            vehicleInfo.forEach((i) => {
                const el = document.querySelector(i.class);
                console.log(i.event, el || i.fallbackValue, el.textContent ?? i.fallbackValue);
                if (el || i.fallbackValue)
                    window.cef.SendMessage(`mouhud:${i.event};${el.textContent ?? i.fallbackValue}`, null);
            })
        }
        
        console.log("[MouHUD] window.mouHudUpdater = ", window.mouHudUpdater);
        if (window.mouHudUpdater) {
            console.log("[MouHUD] Process was killed ", window.mouHudUpdater);
            clearInterval(window.mouHudUpdater);
        }
        window.mouHudUpdater = setInterval(UpdateMouHUD, 300);
        console.log("[MouHUD] Started. ID:", window.mouHudUpdater);
        window.cef.SendMessage(`mouhud:ready;${window.mouHudUpdater ? "1" : "0"}`, null);
    ]],
}
--[[
    <div class="player-info b"><div class="player-info__server-info-bar" style="--server-flag: url(./assets/0d205d4e518d2c1fa13a.webp);">  <div class="player-info__user-stats"><div class="player-info__users-online"><i class="player-info__users-online-icon ui-man"></i> <div class="player-info__users-online-count">1000</div></div> <div class="player-info__user-id"><span class="player-info__user-id-caption">ID:</span> <span class="player-info__user-id-value">613</span></div></div> <div class="player-info__project-logo"><img alt="logo" class="player-info__project-logo-image" src="./assets/62f3553776d01c74d9f0.webp"></div> <div class="player-info__project"><div class="player-info__project-name">Arizona</div> <div class="player-info__project-name-caption">Role Play</div></div> <div class="player-info__server"><div class="player-info__server-number">9</div> <div class="player-info__server-name">Yuma</div></div></div> <div class="player-info__params-wrapper"> <div class="player-info__params"><div class="player-info__indicators"><div class="player-info__indicator"><div class="circle-indicator" style="--svg-width: 50px; --icon-color: #FF1D38; --progress-color: #FF1D38;"><div class="circle-indicator__lines"><svg class="circle-indicator__svg-zone" style="--dashoffset: 0; --dasharray: 141.3716694115407;"><circle class="circle-indicator__total" cx="25" cy="25" r="22.5"></circle><circle class="circle-indicator__current" cx="25" cy="25" r="22.5"></circle></svg></div> <div class="circle-indicator__light"></div> <i class="circle-indicator__icon ui-heart"></i> <i class="circle-indicator__wave-icon ui-wave"></i> <p class="circle-indicator__count">102  </p></div></div> <div class="player-info__indicator"><div class="circle-indicator" style="--svg-width: 50px; --icon-color: #FFFFFF; --progress-color: #FFFFFF;"><div class="circle-indicator__lines"><svg class="circle-indicator__svg-zone" style="--dashoffset: 141.3716694115407; --dasharray: 141.3716694115407;"><circle class="circle-indicator__total" cx="25" cy="25" r="22.5"></circle><circle class="circle-indicator__current" cx="25" cy="25" r="22.5"></circle></svg></div> <div class="circle-indicator__light"></div> <i class="circle-indicator__icon ui-armor"></i> <i class="circle-indicator__wave-icon ui-wave"></i> <p class="circle-indicator__count">0  </p></div></div> <div class="player-info__indicator"><div class="circle-indicator" style="--svg-width: 50px; --icon-color: #F48A28; --progress-color: #F48A28;"><div class="circle-indicator__lines"><svg class="circle-indicator__svg-zone" style="--dashoffset: 93.30530181161686; --dasharray: 141.3716694115407;"><circle class="circle-indicator__total" cx="25" cy="25" r="22.5"></circle><circle class="circle-indicator__current" cx="25" cy="25" r="22.5"></circle></svg></div> <div class="circle-indicator__light"></div> <i class="circle-indicator__icon ui-burger"></i> <i class="circle-indicator__wave-icon ui-wave"></i> <p class="circle-indicator__count">34  </p></div></div> </div> <div class="player-info__gun"><div class="player-info__gun-image-wrapper"><img src="./assets/cb631acc499b0b242834.webp" alt="gun" class="player-info__gun-image"> </div> <div class="player-info__ammo"></div> <div class="player-info__green-zone" style=""><img src="./assets/fe145d15fc9f8dc88c8f.svg" alt="green-zone" class="player-info__green-zone-icon"> <div class="player-info__green-zone-text"><span>Зеленая</span> <span class="player-info__green-zone-text-highlight">зона</span></div></div></div></div></div> <div class="player-info__player-stats"><div class="player-money svelte-ob5qf4"><div class="player-money__list svelte-ob5qf4"><div class="player-money__item svelte-ob5qf4"> <div class="player-money__item-content svelte-ob5qf4"><img class="player-money__item-icon svelte-ob5qf4" src="./assets/92874a98dd84f37f385a.svg" alt="dollar-icon"> <p class="player-money__item-value svelte-ob5qf4"> 35&nbsp;330&nbsp;291</p></div></div></div></div></div></div>

    <div class="player-info b">
    <div class="player-info__server-info-bar" style="--server-flag: url(./assets/0d205d4e518d2c1fa13a.webp)">
        <div class="player-info__user-stats">
            <div class="player-info__users-online">
                <i class="player-info__users-online-icon ui-man"></i>
                <div class="player-info__users-online-count">1000</div>
            </div>
            <div class="player-info__user-id">
                <span class="player-info__user-id-caption">ID:</span>
                <span class="player-info__user-id-value">613</span>
            </div>
        </div>
        <div class="player-info__project-logo">
            <img alt="logo" class="player-info__project-logo-image" src="./assets/62f3553776d01c74d9f0.webp" />
        </div>
        <div class="player-info__project">
            <div class="player-info__project-name">Arizona</div>
            <div class="player-info__project-name-caption">Role Play</div>
        </div>
        <div class="player-info__server">
            <div class="player-info__server-number">9</div>
            <div class="player-info__server-name">Yuma</div>
        </div>
    </div>
    <div class="player-info__params-wrapper">
        <div class="player-info__params">
            <div class="player-info__indicators">
                <div class="player-info__indicator">
                    <div
                        class="circle-indicator"
                        style="--svg-width: 50px; --icon-color: #ff1d38; --progress-color: #ff1d38"
                    >
                        <div class="circle-indicator__lines">
                            <svg
                                class="circle-indicator__svg-zone"
                                style="--dashoffset: 0; --dasharray: 141.3716694115407"
                            >
                                <circle class="circle-indicator__total" cx="25" cy="25" r="22.5"></circle>
                                <circle class="circle-indicator__current" cx="25" cy="25" r="22.5"></circle>
                            </svg>
                        </div>
                        <div class="circle-indicator__light"></div>
                        <i class="circle-indicator__icon ui-heart"></i>
                        <i class="circle-indicator__wave-icon ui-wave"></i>
                        <p class="circle-indicator__count">102</p>
                    </div>
                </div>
                <div class="player-info__indicator">
                    <div
                        class="circle-indicator"
                        style="--svg-width: 50px; --icon-color: #ffffff; --progress-color: #ffffff"
                    >
                        <div class="circle-indicator__lines">
                            <svg
                                class="circle-indicator__svg-zone"
                                style="--dashoffset: 141.3716694115407; --dasharray: 141.3716694115407"
                            >
                                <circle class="circle-indicator__total" cx="25" cy="25" r="22.5"></circle>
                                <circle class="circle-indicator__current" cx="25" cy="25" r="22.5"></circle>
                            </svg>
                        </div>
                        <div class="circle-indicator__light"></div>
                        <i class="circle-indicator__icon ui-armor"></i>
                        <i class="circle-indicator__wave-icon ui-wave"></i>
                        <p class="circle-indicator__count">0</p>
                    </div>
                </div>
                <div class="player-info__indicator">
                    <div
                        class="circle-indicator"
                        style="--svg-width: 50px; --icon-color: #f48a28; --progress-color: #f48a28"
                    >
                        <div class="circle-indicator__lines">
                            <svg
                                class="circle-indicator__svg-zone"
                                style="--dashoffset: 93.30530181161686; --dasharray: 141.3716694115407"
                            >
                                <circle class="circle-indicator__total" cx="25" cy="25" r="22.5"></circle>
                                <circle class="circle-indicator__current" cx="25" cy="25" r="22.5"></circle>
                            </svg>
                        </div>
                        <div class="circle-indicator__light"></div>
                        <i class="circle-indicator__icon ui-burger"></i>
                        <i class="circle-indicator__wave-icon ui-wave"></i>
                        <p class="circle-indicator__count">34</p>
                    </div>
                </div>
            </div>
            <div class="player-info__gun">
                <div class="player-info__gun-image-wrapper">
                    <img src="./assets/cb631acc499b0b242834.webp" alt="gun" class="player-info__gun-image" />
                </div>
                <div class="player-info__ammo"></div>
                <div class="player-info__green-zone" style="">
                    <img
                        src="./assets/fe145d15fc9f8dc88c8f.svg"
                        alt="green-zone"
                        class="player-info__green-zone-icon"
                    />
                    <div class="player-info__green-zone-text">
                        <span>Зеленая</span> <span class="player-info__green-zone-text-highlight">зона</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="player-info__player-stats">
        <div class="player-money svelte-ob5qf4">
            <div class="player-money__list svelte-ob5qf4">
                <div class="player-money__item svelte-ob5qf4">
                    <div class="player-money__item-content svelte-ob5qf4">
                        <img
                            class="player-money__item-icon svelte-ob5qf4"
                            src="./assets/92874a98dd84f37f385a.svg"
                            alt="dollar-icon"
                        />
                        <p class="player-money__item-value svelte-ob5qf4">35&nbsp;330&nbsp;291</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

]]