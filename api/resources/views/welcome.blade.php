<!DOCTYPE html>
<html lang="fr" class="scroll-smooth">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="DR-PHARMA - L'écosystème santé n°1 en Côte d'Ivoire.">
        <title>DR-PHARMA | Le Futur de la Santé</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=plus-jakarta-sans:300,400,500,600,700,800|inter:400,500,600&display=swap" rel="stylesheet" />

        <!-- Tailwind v4 CDN -->
        <script src="https://unpkg.com/@tailwindcss/browser@4"></script>
        
        <style type="text/tailwindcss">
            @theme {
                --font-jakarta: "Plus Jakarta Sans", sans-serif;
                --font-inter: "Inter", sans-serif;
                --color-primary: #2563eb;
                --color-secondary: #0f172a;
            }
            .glass {
                background: rgba(255, 255, 255, 0.7);
                backdrop-filter: blur(12px);
                -webkit-backdrop-filter: blur(12px);
                border: 1px solid rgba(255, 255, 255, 0.5);
            }
            .glass-dark {
                background: rgba(15, 23, 42, 0.6);
                backdrop-filter: blur(12px);
                -webkit-backdrop-filter: blur(12px);
                border: 1px solid rgba(255, 255, 255, 0.05);
            }
            .bg-noise {
                background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.05'/%3E%3C/svg%3E");
            }
            .mesh-gradient {
                background-color: #f8fafc;
                background-image: 
                    radial-gradient(at 0% 0%, hsla(217,91%,60%,0.2) 0px, transparent 50%),
                    radial-gradient(at 100% 0%, hsla(186,100%,41%,0.15) 0px, transparent 50%),
                    radial-gradient(at 100% 100%, hsla(262,80%,50%,0.1) 0px, transparent 50%),
                    radial-gradient(at 0% 100%, hsla(217,91%,60%,0.15) 0px, transparent 50%);
            }
            .reveal {
                opacity: 0;
                transform: translateY(30px);
                transition: all 0.8s cubic-bezier(0.16, 1, 0.3, 1);
            }
            .reveal.active {
                opacity: 1;
                transform: translateY(0);
            }
            .animation-delay-200 { transition-delay: 200ms; }
            .animation-delay-400 { transition-delay: 400ms; }
        </style>
    </head>
    <body class="font-jakarta text-slate-900 bg-slate-50 antialiased overflow-x-hidden selection:bg-blue-600 selection:text-white">
        
        <!-- Navigation -->
        <nav class="fixed w-full z-50 top-0 transition-all duration-300 glass shadow-sm shadow-blue-900/5">
            <div class="max-w-7xl mx-auto px-6 lg:px-8">
                <div class="flex justify-between items-center h-20">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-linear-to-br from-blue-600 to-indigo-600 flex items-center justify-center text-white font-extrabold text-lg shadow-lg shadow-blue-500/30">
                            DR
                        </div>
                        <span class="font-bold text-xl tracking-tight text-slate-900">DR-PHARMA</span>
                    </div>
                    <div class="hidden md:flex gap-8">
                        <a href="#apps" class="text-sm font-medium text-slate-600 hover:text-blue-600 transition-colors">Nos Solutions</a>
                        <a href="#features" class="text-sm font-medium text-slate-600 hover:text-blue-600 transition-colors">Fonctionnalités</a>
                    </div>
                    <button class="bg-slate-900 hover:bg-slate-800 text-white px-5 py-2.5 rounded-full text-sm font-semibold transition-all hover:scale-105 active:scale-95 shadow-xl shadow-slate-900/10">
                        Télécharger
                    </button>
                </div>
            </div>
        </nav>

        <!-- Hero Section -->
        <section class="relative min-h-[90vh] flex items-center pt-20 overflow-hidden mesh-gradient bg-noise">
            <div class="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20 brightness-100 contrast-150 mix-blend-overlay"></div>
            
            <div class="max-w-7xl mx-auto px-6 lg:px-8 relative z-10 w-full">
                <div class="grid lg:grid-cols-2 gap-12 lg:gap-20 items-center">
                    <div class="text-left reveal active">
                        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-50 border border-blue-100 text-blue-700 text-xs font-bold tracking-wide uppercase mb-8 shadow-sm">
                            <span class="w-2 h-2 rounded-full bg-blue-600 animate-pulse"></span>
                            Innovation Santé 2026
                        </div>
                        
                        <h1 class="text-5xl md:text-7xl font-extrabold tracking-tight text-slate-900 mb-8 leading-[1.1]">
                            La santé, <br/>
                            <span class="text-transparent bg-clip-text bg-linear-to-r from-blue-600 via-indigo-600 to-purple-600">
                                réinventée.
                            </span>
                        </h1>
                        
                        <p class="text-xl text-slate-600 mb-10 leading-relaxed max-w-lg font-inter">
                            Une infrastructure digitale complète connectant patients, pharmacies et livreurs pour une expérience de soin fluide et sécurisée.
                        </p>

                        <div class="flex flex-col sm:flex-row gap-4">
                            <button onclick="document.getElementById('apps').scrollIntoView({behavior: 'smooth'})" class="px-8 py-4 bg-blue-600 text-white rounded-2xl font-bold text-lg hover:bg-blue-700 transition-all shadow-lg shadow-blue-600/30 hover:-translate-y-1 flex items-center justify-center gap-2 group">
                                Commencer maintenant
                                <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path></svg>
                            </button>
                            <button class="px-8 py-4 bg-white text-slate-700 rounded-2xl font-bold text-lg border border-slate-200 hover:bg-slate-50 transition-all hover:-translate-y-1 flex items-center justify-center gap-2 shadow-sm">
                                <svg class="w-5 h-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                                Voir la démo
                            </button>
                        </div>
                        
                        <div class="mt-12 flex items-center gap-4 text-sm text-slate-500 font-medium">
                            <div class="flex -space-x-2">
                                <div class="w-8 h-8 rounded-full bg-slate-200 border-2 border-white"></div>
                                <div class="w-8 h-8 rounded-full bg-slate-300 border-2 border-white"></div>
                                <div class="w-8 h-8 rounded-full bg-slate-400 border-2 border-white"></div>
                            </div>
                            <span>Déjà utilisé par +5000 ivoiriens</span>
                        </div>
                    </div>
                    
                    <div class="relative lg:-mr-20 reveal animation-delay-200">
                        <!-- Abstract Phone Mockup Composition -->
                        <div class="relative w-full aspect-square max-w-2xl mx-auto">
                            <!-- Background Blobs -->
                            <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[120%] h-[120%] bg-blue-500/20 rounded-full blur-3xl animate-pulse"></div>
                            
                            <!-- Main Visual Card (App Interface Abstract) -->
                            <div class="absolute inset-4 bg-white rounded-[2.5rem] shadow-2xl shadow-blue-900/10 border border-slate-100 overflow-hidden transform -rotate-2 transition-transform hover:rotate-0 duration-500">
                                <div class="absolute top-0 w-full h-80 bg-linear-to-b from-blue-50/50 to-transparent"></div>
                                
                                <!-- Header UI -->
                                <div class="p-8">
                                    <div class="flex justify-between items-center mb-8">
                                        <div class="w-8 h-8 rounded-lg bg-blue-100"></div>
                                        <div class="w-32 h-4 rounded-full bg-slate-100"></div>
                                    </div>
                                    <!-- Search Bar -->
                                    <div class="w-full h-14 bg-white rounded-2xl shadow-sm border border-slate-100 mb-8 flex items-center px-4 gap-3">
                                        <div class="w-5 h-5 rounded-full bg-slate-100"></div>
                                        <div class="w-40 h-3 rounded-full bg-slate-50"></div>
                                    </div>
                                    <!-- Grid Items -->
                                    <div class="grid grid-cols-2 gap-4">
                                        <div class="aspect-square rounded-2xl bg-blue-50 p-4">
                                            <div class="w-10 h-10 rounded-xl bg-blue-500 mb-3 text-white flex items-center justify-center font-bold">💊</div>
                                            <div class="w-20 h-3 rounded-full bg-blue-200 mb-2"></div>
                                            <div class="w-12 h-2 rounded-full bg-blue-100"></div>
                                        </div>
                                        <div class="aspect-square rounded-2xl bg-green-50 p-4">
                                            <div class="w-10 h-10 rounded-xl bg-green-500 mb-3 text-white flex items-center justify-center font-bold">🏥</div>
                                            <div class="w-20 h-3 rounded-full bg-green-200 mb-2"></div>
                                            <div class="w-12 h-2 rounded-full bg-green-100"></div>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Floating Elements -->
                                <div class="absolute bottom-8 right-8 bg-white p-4 rounded-2xl shadow-xl shadow-slate-200 border border-slate-50 flex items-center gap-3 animate-bounce" style="animation-duration: 3s;">
                                    <div class="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center text-green-600">✓</div>
                                    <div>
                                        <div class="text-xs text-slate-400 font-bold">Commande</div>
                                        <div class="text-sm font-bold text-slate-800">Livrée à 14:30</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Bento Grid Apps Section -->
        <section id="apps" class="py-32 bg-slate-50 relative overflow-hidden">
            <div class="max-w-7xl mx-auto px-6 lg:px-8 relative z-10">
                <div class="text-center max-w-3xl mx-auto mb-20 reveal">
                    <h2 class="text-3xl md:text-5xl font-bold text-slate-900 mb-6 tracking-tight">Un écosystème, <br/><span class="text-blue-600">trois expériences.</span></h2>
                    <p class="text-lg text-slate-600">Une suite d'applications interconnectées conçues pour chaque acteur de la chaîne de santé.</p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-6 lg:grid-cols-12 gap-6 h-auto md:h-150">
                    <!-- Main Card: Client -->
                    <div class="md:col-span-6 lg:col-span-6 bg-white rounded-4xl p-8 md:p-12 shadow-2xl shadow-slate-200/50 border border-slate-100 relative overflow-hidden group hover:border-blue-200 transition-colors reveal">
                        <div class="absolute top-0 right-0 w-64 h-64 bg-blue-50 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2 group-hover:bg-blue-100 transition-colors"></div>
                        <div class="relative z-10 h-full flex flex-col justify-between">
                            <div>
                                <div class="w-14 h-14 rounded-2xl bg-blue-600 text-white flex items-center justify-center mb-6 shadow-lg shadow-blue-500/30">
                                    <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
                                </div>
                                <h3 class="text-3xl font-bold text-slate-900 mb-3">Patient</h3>
                                <p class="text-slate-600 text-lg">Trouvez vos médicaments, comparez les prix et faites-vous livrer en moins de 30 min.</p>
                            </div>
                            <div class="mt-8">
                                <ul class="space-y-3 mb-8">
                                    <li class="flex items-center gap-3 text-slate-600"><span class="w-1.5 h-1.5 rounded-full bg-blue-500"></span>Géolocalisation pharmacies</li>
                                    <li class="flex items-center gap-3 text-slate-600"><span class="w-1.5 h-1.5 rounded-full bg-blue-500"></span>Scan d'ordonnance IA</li>
                                </ul>
                                <button onclick="alert('Bientôt disponible')" class="w-full py-3 bg-slate-900 text-white rounded-xl font-bold hover:bg-slate-800 transition-colors">Télécharger l'App</button>
                            </div>
                        </div>
                    </div>

                    <div class="md:col-span-6 lg:col-span-6 flex flex-col gap-6">
                        <!-- Secondary Card: Pharmacy -->
                        <div class="flex-1 bg-white rounded-4xl p-8 shadow-xl shadow-slate-200/50 border border-slate-100 relative overflow-hidden group hover:border-emerald-200 transition-colors reveal animation-delay-200">
                            <div class="absolute top-0 right-0 w-32 h-32 bg-emerald-50 rounded-full blur-2xl group-hover:bg-emerald-100 transition-colors"></div>
                            <div class="flex items-start justify-between">
                                <div>
                                    <div class="w-12 h-12 rounded-2xl bg-emerald-500 text-white flex items-center justify-center mb-4 shadow-lg shadow-emerald-500/30">
                                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path></svg>
                                    </div>
                                    <h3 class="text-2xl font-bold text-slate-900 mb-2">Pharmacien Pro</h3>
                                    <p class="text-slate-600">Digitalisez votre officine. Gestion de stock et commandes en temps réel.</p>
                                </div>
                            </div>
                        </div>

                        <!-- Secondary Card: Courier -->
                        <div class="flex-1 bg-white rounded-4xl p-8 shadow-xl shadow-slate-200/50 border border-slate-100 relative overflow-hidden group hover:border-orange-200 transition-colors reveal animation-delay-400">
                            <div class="absolute top-0 right-0 w-32 h-32 bg-orange-50 rounded-full blur-2xl group-hover:bg-orange-100 transition-colors"></div>
                            <div class="flex items-start justify-between">
                                <div>
                                    <div class="w-12 h-12 rounded-2xl bg-orange-500 text-white flex items-center justify-center mb-4 shadow-lg shadow-orange-500/30">
                                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                                    </div>
                                    <h3 class="text-2xl font-bold text-slate-900 mb-2">Coursier Fleet</h3>
                                    <p class="text-slate-600">Générez des revenus en livrant des produits essentiels. Flexibilité totale.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Features Matrix -->
        <section id="features" class="py-32 bg-slate-900 text-white relative overflow-hidden">
            <!-- Grid Background -->
            <div class="absolute inset-0 bg-[linear-gradient(to_right,#1e293b_1px,transparent_1px),linear-gradient(to_bottom,#1e293b_1px,transparent_1px)] bg-size-[40px_40px] opacity-20"></div>
            
            <div class="max-w-7xl mx-auto px-6 lg:px-8 relative z-10">
                <div class="mb-20">
                    <h2 class="text-3xl md:text-5xl font-bold mb-6">Technologie de pointe</h2>
                    <p class="text-slate-400 text-lg max-w-2xl">Nous n'avons pas seulement créé une application, nous avons repensé la logistique pharmaceutique.</p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                    <div class="border border-slate-800 bg-slate-800/50 p-8 rounded-3xl hover:bg-slate-800 transition-colors reveal">
                        <div class="text-blue-500 mb-6 text-4xl">🔍</div>
                        <h3 class="text-xl font-bold mb-3">Recherche Unifiée</h3>
                        <p class="text-slate-400 leading-relaxed">Algorithme puissant capable de trouver la disponibilité d'un médicament dans 200+ pharmacies en millisecondes.</p>
                    </div>
                    <div class="border border-slate-800 bg-slate-800/50 p-8 rounded-3xl hover:bg-slate-800 transition-colors reveal animation-delay-200">
                        <div class="text-blue-500 mb-6 text-4xl">🛡️</div>
                        <h3 class="text-xl font-bold mb-3">Sécurité Maximale</h3>
                        <p class="text-slate-400 leading-relaxed">Toutes les données de santé sont cryptées de bout en bout. Conformité stricte aux normes médicales.</p>
                    </div>
                    <div class="border border-slate-800 bg-slate-800/50 p-8 rounded-3xl hover:bg-slate-800 transition-colors reveal animation-delay-400">
                        <div class="text-blue-500 mb-6 text-4xl">⚡</div>
                        <h3 class="text-xl font-bold mb-3">Temps Réel</h3>
                        <p class="text-slate-400 leading-relaxed">Suivi GPS des coursiers à la seconde près. Notifications instantanées à chaque étape.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer class="bg-slate-950 border-t border-slate-900 pt-20 pb-10 text-slate-400">
            <div class="max-w-7xl mx-auto px-6 lg:px-8">
                <div class="grid grid-cols-2 md:grid-cols-4 gap-12 mb-20">
                    <div class="col-span-2">
                        <div class="flex items-center gap-3 mb-6">
                            <div class="w-10 h-10 rounded-xl bg-blue-600 flex items-center justify-center text-white font-bold">DR</div>
                            <span class="text-2xl font-bold text-white tracking-tight">DR-PHARMA</span>
                        </div>
                        <p class="max-w-sm text-slate-500">
                            La première infrastructure numérique dédiée à la santé en Côte d'Ivoire. Nous sauvons des vies en accélérant l'accès aux soins.
                        </p>
                    </div>
                    <div>
                        <h4 class="text-white font-bold mb-6">Plateforme</h4>
                        <ul class="space-y-4 text-sm">
                            <li><a href="#" class="hover:text-blue-500 transition-colors">Pour les patients</a></li>
                            <li><a href="#" class="hover:text-blue-500 transition-colors">Pour les pharmaciens</a></li>
                            <li><a href="#" class="hover:text-blue-500 transition-colors">Devenir coursier</a></li>
                        </ul>
                    </div>
                    <div>
                        <h4 class="text-white font-bold mb-6">Légal</h4>
                        <ul class="space-y-4 text-sm">
                            <li><a href="#" class="hover:text-blue-500 transition-colors">Confidentialité</a></li>
                            <li><a href="#" class="hover:text-blue-500 transition-colors">Conditions d'utilisation</a></li>
                            <li><a href="#" class="hover:text-blue-500 transition-colors">Mentions légales</a></li>
                        </ul>
                    </div>
                </div>
                
                <div class="border-t border-slate-900 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
                    <p class="text-sm">© 2026 DR-PHARMA. All rights reserved.</p>
                    <div class="flex items-center gap-2 text-sm font-medium">
                        <span class="w-2 h-2 rounded-full bg-green-500"></span>
                        Systèmes opérationnels
                        <span class="ml-4">🇨🇮 Abidjan, Côte d'Ivoire</span>
                    </div>
                </div>
            </div>
        </footer>

        <!-- Scroll Animation Script -->
        <script>
            document.addEventListener('DOMContentLoaded', () => {
                const observerOptions = {
                    root: null,
                    rootMargin: '0px',
                    threshold: 0.1
                };

                const observer = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            entry.target.classList.add('active');
                            observer.unobserve(entry.target);
                        }
                    });
                }, observerOptions);

                const revealElements = document.querySelectorAll('.reveal');
                revealElements.forEach(el => observer.observe(el));
            });
        </script>
    </body>
</html>
