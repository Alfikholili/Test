<script>
            function fetchDownload({ shareid, uk, sign, timestamp, fs_id }) {
                return fetch("/api/get-download", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ shareid, uk, sign, timestamp, fs_id }),
                }).then(async function (res) {
                    return await res.json()
                })
            }
            
            function fetchDownloadP({ shareid, uk, sign, timestamp, fs_id }) {
                return fetch("/api/get-downloadp", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ shareid, uk, sign, timestamp, fs_id }),
                }).then(async (res) => await res.json())
            }

            function fetchInfo(shortUrl, pwd = ''){
                return fetch(`/api/get-info-new?shorturl=${shortUrl}&pwd=${pwd}`).then(async function (res) {
                        const body = await res.json()

                        if (!body.ok) return alert(body.message)

                        // handle Info
                        function recursiveList(list) {
                            return list.map((item) => ({
                                isDir: item.is_dir != 0,
                                name: item.filename,
                                category: item.is_dir != 0 || parseInt(item.category),
                                size: item.is_dir != 0 || formatStorageSize(parseInt(item.size)),
                                children:
                                    item.children && item.children.length > 0
                                        ? recursiveList(item.children)
                                        : undefined,
                                downloadAction:
                                    item.is_dir != 0 ||
                                    async function () {
                                        const res = await fetchDownload({
                                            shareid: body.shareid,
                                            uk: body.uk,
                                            sign: body.sign,
                                            timestamp: body.timestamp,
                                            fs_id: item.fs_id,
                                        })

                                        if (!res.ok) return alert(res.message)

                                        return res.downloadLink
                                    },
                                downloadActionP:
                                    item.is_dir != 0 ||
                                    async function() {
                                        const res = await fetchDownloadP({
                                        shareid: body.shareid,
                                        uk: body.uk,
                                        sign: body.sign,
                                        timestamp: body.timestamp,
                                        fs_id: item.fs_id,
                                    });
                                    if (!res.ok) return alert(res.message)
                                    return res.downloadLink
                                },
                            }))
                        }

                        return recursiveList(body.list)
                    })

            }

            const getLinkButton = document.getElementById("get-link-button")
            const inputUrl = document.getElementById("input-url")
            const inputPassword = document.getElementById("input-password")
            const outputElement = document.querySelector(".output")
            const treeViewElement = document.querySelector(".tree-view")
            const placeholders = ['https://terabox.com/s/117NfiRSK_e4ImEEDqQGh_g', 'https://www.terabox.com/sharing/link?surl=17NfiRSK_e4ImEEDqQGh_g', 'Enter your TeraBox URL Here'];
            let ips = 0;
            setInterval(() => {
                inputUrl.setAttribute('placeholder', placeholders[ips]);
                ips = (ips + 1) % placeholders.length;
            }, 2000);

            getLinkButton.addEventListener("click", async function () {
                const url = inputUrl.value
                const pwd = inputPassword.value

                if(!url) return alert('URL must not be empty!')

                const regex = /(?:surl=|\/)([a-zA-Z0-9-_]+)$/
                const match = url.match(regex)
                if (match) {
                    const shortUrl = match[1]

                    treeViewElement.innerHTML = '<p style="text-align:center;"><i class="fa-solid fa-circle-notch fa-spin"></i> Loading...</p>'
                    getLinkButton.disabled = true
                    outputElement.style.display = 'block'
                    
                    const d = await fetchInfo(shortUrl, pwd)
                    
                    getLinkButton.disabled = false
                    treeViewElement.innerHTML = ''
                    
                    TreeView(d, treeViewElement)
                } else {
                    alert("Unsupported URL")
                    getLinkButton.disabled = false
                }
            })
        </script>
